-- =====================================================================
-- Adjustments: corrections confirmed with the business
-- Run last, after the data quality checks:
--   psql penang_microworks -f sql/adjustments.sql
--
-- NOTE ON PRACTICE
-- In a real finance team, FP&A flags the issue, accounting posts the
-- reclass journal in Oracle with approval, and the fix flows into the
-- data warehouse at the next refresh. This file mirrors that outcome.
-- Original lines are never edited; corrections are posted as new lines.
--
-- What each DQ issue needs:
--   DQ1 Missing department  -> ADJ1 below
--   DQ2 Future-dated line   -> no adjustment: on hold in gl_exceptions
--   DQ3 Duplicate line      -> ADJ2 below
--   DQ4 Missing fields      -> no adjustment: on hold in gl_exceptions
--   DQ5 Unmapped account    -> ADJ3 below
--   DQ6 June marketing      -> no adjustment: genuine trade show
--   DQ7 Revenue gap         -> no adjustment: explained by DQ3
-- =====================================================================


-- ---------------------------------------------------------------------
-- ADJ1 (DQ1): reclass journal, August travel from Unassigned to
-- Sales & Marketing. Confirmed with the S&M manager.
-- Dr Travel (S&M) / Cr Travel (Unassigned): the journal nets to zero,
-- so total opex doesn't change. Line 556 itself is left untouched.
-- ---------------------------------------------------------------------
DELETE FROM gl_actuals WHERE line_id IN (9001, 9002);   -- lets the file re-run safely

INSERT INTO gl_actuals (line_id, month, account_id, department_id, product_id, amount) VALUES
    (9001, DATE '2026-08-01', 10, 3,    NULL,  26678.86),   -- Dr Travel, Sales & Marketing
    (9002, DATE '2026-08-01', 10, NULL, NULL, -26678.86);   -- Cr Travel, Unassigned


-- ---------------------------------------------------------------------
-- ADJ2 (DQ3): reverse the duplicate September revenue line
-- Line 601 (CON-200 product sales) was loaded twice when the upload was
-- re-run. Confirmed with accounting. The original credit was -290,737.44,
-- so the reversal is an equal and opposite debit.
-- In practice: accounting would reverse the duplicate journal in Oracle.
-- ---------------------------------------------------------------------
DELETE FROM gl_actuals WHERE line_id = 9003;   -- lets the file re-run safely

INSERT INTO gl_actuals (line_id, month, account_id, department_id, product_id, amount) VALUES
    (9003, DATE '2026-09-01', 1, NULL, 6, 290737.44);   -- Dr Product sales, reverses duplicate of line 601


-- ---------------------------------------------------------------------
-- ADJ3 (DQ5): add account 99 to the reporting account mapping
-- Accounting created it in Oracle for software subscriptions, but it
-- wasn't added to the mapping FP&A uses to build the P&L.
-- In practice: the finance systems team updates the account mapping.
-- ---------------------------------------------------------------------
DELETE FROM accounts WHERE account_id = 99;   -- lets the file re-run safely

INSERT INTO accounts (account_id, account_code, account_name, account_type, fs_line, fs_sort_order) VALUES
    (99, '6700', 'Software subscriptions', 'Opex', 'Other operating expenses', 70);


-- =====================================================================
-- Checks
-- =====================================================================

-- ADJ1: S&M picks up the travel, Unassigned nets to zero
SELECT department_id, SUM(amount) AS amount
FROM gl_actuals
WHERE line_id IN (556, 9001, 9002)
GROUP BY department_id;

-- ADJ2: GL revenue ties to sales_volume every month (expect 0 rows)
WITH gl AS (
    SELECT month, -SUM(amount) AS gl_revenue
    FROM gl_actuals
    WHERE account_id = 1                    -- 4000 Product sales
        AND month < '2026-10-01'
    GROUP BY month
)
, sv AS (
    SELECT month, SUM(actual_revenue) AS sv_revenue
    FROM sales_volume
    WHERE month < '2026-10-01'
    GROUP BY month
)
SELECT gl.month, gl.gl_revenue, sv.sv_revenue
FROM gl
LEFT JOIN sv
    ON gl.month = sv.month
WHERE gl.gl_revenue IS DISTINCT FROM sv.sv_revenue;

-- ADJ3: every GL line maps to a known account (expect 0 rows)
SELECT g.line_id, g.account_id
FROM gl_actuals AS g
LEFT JOIN accounts AS a
    ON g.account_id = a.account_id
WHERE g.account_id IS NOT NULL
    AND a.account_id IS NULL;
