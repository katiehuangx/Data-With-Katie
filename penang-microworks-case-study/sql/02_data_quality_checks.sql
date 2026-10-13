-- =====================================================================
-- Data quality (DQ) checks on gl_actuals
-- Run: psql penang_microworks -f sql/02_data_quality_checks.sql
--
-- Golden rule: never silently drop bad rows. Each problem is either
--   (a) put on hold (left out of gl_actuals_clean), or
--   (b) kept and labelled (e.g. "Unassigned", "Unmapped") so totals still tie.
-- As-of month for this analysis: September 2026.
-- =====================================================================


-- ---------------------------------------------------------------------
-- DQ1. NULL in a column that should be filled
-- Opex lines need a department; revenue and cost of sales lines need a product.
-- Treatment: keep, report as "Unassigned" (an INNER JOIN would silently drop them).
-- ---------------------------------------------------------------------
SELECT g.line_id, g.month, a.account_code, a.account_type, g.department_id, g.product_id, g.amount
FROM gl_actuals AS g
JOIN accounts AS a ON a.account_id = g.account_id
WHERE (a.account_type = 'Opex' AND g.department_id IS NULL)
   OR (a.account_type IN ('Revenue', 'COGS') AND g.product_id IS NULL);


-- ---------------------------------------------------------------------
-- DQ2. Future date
-- Anything after the as-of month can't be an actual yet.
-- Treatment: put on hold and flag for review (often a mis-keyed date).
-- ---------------------------------------------------------------------
SELECT *
FROM gl_actuals
WHERE month > DATE '2026-09-01';


-- ---------------------------------------------------------------------
-- DQ3. Same record twice
-- line_id should be unique. Duplicates double-count the amount.
-- Treatment: confirm with accounting, then reverse the extra copy with a
-- reversal entry (ADJ2 in adjustments.sql). The line stays in the GL.
-- ---------------------------------------------------------------------
SELECT line_id, COUNT(*) AS copies, MIN(amount) AS amount
FROM gl_actuals
GROUP BY line_id
HAVING COUNT(*) > 1;


-- ---------------------------------------------------------------------
-- DQ4. Mandatory field missing
-- A line with no line_id, month, account or amount can't go on the P&L.
-- Treatment: put on hold.
-- ---------------------------------------------------------------------
SELECT *
FROM gl_actuals
WHERE line_id IS NULL
   OR month IS NULL
   OR account_id IS NULL
   OR amount IS NULL;


-- ---------------------------------------------------------------------
-- DQ5. Value never seen before
-- Anti-join: rows whose code has no match in the master table.
-- Treatment: keep, show as "Unmapped" on the P&L until finance maps it.
-- ---------------------------------------------------------------------
SELECT g.*, 'account' AS unmapped_field
FROM gl_actuals AS g
LEFT JOIN accounts AS a ON a.account_id = g.account_id
WHERE g.account_id IS NOT NULL AND a.account_id IS NULL
UNION ALL
SELECT g.*, 'department'
FROM gl_actuals AS g
LEFT JOIN departments AS d ON d.department_id = g.department_id
WHERE g.department_id IS NOT NULL AND d.department_id IS NULL
UNION ALL
SELECT g.*, 'product'
FROM gl_actuals AS g
LEFT JOIN products AS p ON p.product_id = g.product_id
WHERE g.product_id IS NOT NULL AND p.product_id IS NULL;


-- ---------------------------------------------------------------------
-- DQ6. Tomorrow doesn't look like today
-- Compare each account's monthly total with the prior month; flag moves over 50%.
-- Treatment: investigate. A flag is a question, not proof of an error.
-- ---------------------------------------------------------------------
WITH monthly AS (
    SELECT g.month, a.account_code, a.account_name, SUM(g.amount) AS total
    FROM gl_actuals AS g
    JOIN accounts AS a ON a.account_id = g.account_id
    WHERE g.month <= DATE '2026-09-01'
      AND g.amount IS NOT NULL
    GROUP BY g.month, a.account_code, a.account_name
),
compared AS (
    SELECT *,
           LAG(total) OVER (PARTITION BY account_code ORDER BY month) AS prior_total
    FROM monthly
)
SELECT month, account_code, account_name,
       ROUND(prior_total, 0) AS prior_month,
       ROUND(total, 0)       AS this_month,
       ROUND((total - prior_total) / ABS(prior_total) * 100, 1) AS pct_change
FROM compared
WHERE prior_total IS NOT NULL
  AND ABS(total - prior_total) / ABS(prior_total) > 0.50
ORDER BY month, account_code;


-- ---------------------------------------------------------------------
-- DQ7. Reconciliation: GL revenue vs the sales subledger
-- Two sources that should agree. A gap means one of them has a problem.
-- Expect a September gap here, explained by DQ3; it ties after ADJ2.
-- ---------------------------------------------------------------------
WITH gl AS (
    SELECT month, -SUM(amount) AS gl_revenue
    FROM gl_actuals
    WHERE account_id = 1                  -- 4000 Product sales
      AND month <= DATE '2026-09-01'
    GROUP BY month
),
sv AS (
    SELECT month, SUM(actual_revenue) AS sales_revenue
    FROM sales_volume
    WHERE actual_revenue IS NOT NULL
    GROUP BY month
)
SELECT sv.month, gl.gl_revenue, sv.sales_revenue,
       gl.gl_revenue - sv.sales_revenue AS difference
FROM sv
LEFT JOIN gl ON gl.month = sv.month
WHERE gl.gl_revenue IS DISTINCT FROM sv.sales_revenue;


-- =====================================================================
-- DQ summary report: one row per check (goes in the README)
-- =====================================================================
WITH checks AS (
    SELECT 'DQ1 NULL department or product' AS check_name,
           COUNT(*) AS rows_found, 'Reclassed to S&M (ADJ1)' AS treatment
    FROM gl_actuals g JOIN accounts a ON a.account_id = g.account_id
    WHERE (a.account_type = 'Opex' AND g.department_id IS NULL)
       OR (a.account_type IN ('Revenue', 'COGS') AND g.product_id IS NULL)
    UNION ALL
    SELECT 'DQ2 Future-dated', COUNT(*), 'On hold'
    FROM gl_actuals WHERE month > DATE '2026-09-01'
    UNION ALL
    SELECT 'DQ3 Duplicated line_id', COUNT(*), 'Extra copy reversed (ADJ2)'
    FROM (SELECT line_id FROM gl_actuals GROUP BY line_id HAVING COUNT(*) > 1) AS d
    UNION ALL
    SELECT 'DQ4 Missing mandatory field', COUNT(*), 'On hold'
    FROM gl_actuals
    WHERE line_id IS NULL OR month IS NULL OR account_id IS NULL OR amount IS NULL
    UNION ALL
    SELECT 'DQ5 Unmapped account', COUNT(*), 'Mapped to 6700 (ADJ3)'
    FROM gl_actuals g LEFT JOIN accounts a ON a.account_id = g.account_id
    WHERE g.account_id IS NOT NULL AND a.account_id IS NULL
)
SELECT * FROM checks
UNION ALL
SELECT 'Total rows loaded', (SELECT COUNT(*) FROM gl_actuals), '';
