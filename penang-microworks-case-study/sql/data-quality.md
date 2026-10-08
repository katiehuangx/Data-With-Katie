# Data Quality Checks: Issues found in the September 2026 GL extract

You've just received the September GL extract from Oracle. Before building the variance pack, you run your usual checks and hit seven issues. For each one: find the rows, decide the treatment, and note it for the README. Every bad row is either put on hold with a reason or corrected with an adjusting entry, never silently dropped.

## DQ1. The missing department

The Sales & Marketing manager says August travel in your OPEX report is lower than her team's claims.
- Task: find OPEX lines with no department.

```sql
SELECT 
    g.line_id, 
    g.month, 
    a.account_code,
    a.account_type,
    g.department_id, 
    g.product_id, 
    g.amount
FROM gl_actuals AS g
INNER JOIN accounts AS a
  ON a.account_id = g.account_id
WHERE (a.account_type = 'Opex' AND g.department_id IS NULL);
```

```
 line_id |   month    | account_code | account_type | department_id | product_id |  amount  
---------+------------+--------------+--------------+---------------+------------+----------
     556 | 2026-08-01 | 6400         | Opex         |               |            | 26678.86
```

That's the S&M manager's missing travel claims. The cost was posted, but it's not assigned to the cost center (`department_id`), so it doesn't show up in her department's report.

Treatment: After confirming with the S&M manager, I reclassed the cost to Sales & Marketing with a journal entry in `sql/adjustments.sql` rather than editing the original line:
- Healthy accounting practice is to correct records with an adjusting entry, not by overwriting them 
- This is to ensure proper audit trail showing what changed and why.

```sql
-- Reclass journal: Aug travel from Unassigned to Sales & Marketing
INSERT INTO gl_actuals (line_id, month, account_id, department_id, product_id, amount) VALUES
    (9001, DATE '2026-08-01', 10, 3,    NULL,  26678.86),   -- Dr Travel, Sales & Marketing
    (9002, DATE '2026-08-01', 10, NULL, NULL, -26678.86);   -- Cr Travel, Unassigned
```

The double entry with original entry:

```
 line_id |   month    | account_code | account_type | department_id | product_id |   amount  | 
---------+------------+--------------+--------------+---------------+------------+-----------
     556 | 2026-08-01 | 6400         | Opex         |               |            |  26678.86 
    9001 | 2026-08-01 | 6400         | Opex         |             3 |            |  26678.86 
    9002 | 2026-08-01 | 6400         | Opex         |               |            | -26678.86 
```

556 is the original entry, 9001 the debit to Sales & Marketing, and 9002 the credit out of Unassigned. 

To check 
```sql
SELECT SUM(amount) AS journal_balance
FROM gl_actuals
WHERE line_id IN (9001, 9002);
```

```
Net effect of reclass:
 department_id |  amount  
---------------+----------
             3 | 26678.86 
               |     0.00 
```

The travel claims are now reflected under Sales & Marketing and the Unassigned lines (556 and 9002) cancel out to zero. Total OPEX is unchanged.

In practice, the accounting team would post this reclass in Oracle and it'll flow into the data warehouse at the next refresh.

## DQ2. Entries from the future

You're reporting as of September, but the extract seems to run past it.
Task: find any lines dated after September 2026

```sql
SELECT
    g.line_id,
    g.month,
    a.account_code,
    a.account_name,
    a.account_type,
    d.department_name,
    g.amount
FROM gl_actuals as g
LEFT JOIN accounts as a
    ON g.account_id = a.account_id
LEFT JOIN departments as d
    ON g.department_id = d.department_id
WHERE month > '2026-09-30';
```

```
 line_id |   month    | account_code |   account_name    | account_type |     department_name      |  amount  
---------+------------+--------------+-------------------+--------------+--------------------------+----------
     631 | 2026-10-01 | 6500         | Professional fees | Opex         | General & Administrative | 15000.00
```     

• Decide: Can these be actuals? Or is this a budgeted amount that was incorrectly posted as actuals?

```sql
SELECT
    b.line_id,
    b.month,
    a.account_code,
    a.account_name,
    a.account_type,
    d.department_name,
    b.amount
FROM gl_budget AS b
LEFT JOIN accounts AS a
    ON b.account_id = a.account_id
LEFT JOIN departments AS d
    ON b.department_id = d.department_id
WHERE b.month > '2026-09-30'
    AND a.account_code = '6500'
    AND d.department_name = 'General & Administrative';
```

Well, from this check, we can tell budgeted professional fees are RM48,000 per month so the RM15,000 could be actuals and there could be possibly more actuals. However, hard to tell unless we confirmed this with the accountant. 

```
 line_id |   month    | account_code |   account_name    | account_type |     department_name      |  amount  
---------+------------+--------------+-------------------+--------------+--------------------------+----------
     519 | 2026-10-01 | 6500         | Professional fees | Opex         | General & Administrative | 48000.00
     571 | 2026-11-01 | 6500         | Professional fees | Opex         | General & Administrative | 48000.00
     623 | 2026-12-01 | 6500         | Professional fees | Opex         | General & Administrative | 48000.00
```     

Treatment: To hold off and confirm with the accountant. 

## DQ3. The double-loaded batch

The Oracle support team mentions a September revenue upload was re-run after a timeout.
Your task: find any line_id that appears more than once
Decide: which copy do you keep, and what happens to the rest?


```sql
WITH duplicate_rows AS (
    SELECT line_id
    FROM gl_actuals
    WHERE month >= '2026-09-01'
        AND month < '2026-10-01'
    GROUP BY line_id
    HAVING COUNT(line_id) > 1
)

SELECT 
    g.line_id,
    g.month,
    a.account_code,
    a.account_name,
    a.account_type,
    d.department_name,
    g.amount
FROM gl_actuals AS g
INNER JOIN duplicate_rows AS r
    ON g.line_id = r.line_id
LEFT JOIN accounts AS a
    ON g.account_id = a.account_id
LEFT JOIN departments AS d
    ON g.department_id = d.department_id
WHERE a.account_type = 'Revenue';
```

```
 line_id |   month    | account_code | account_name  | account_type | department_name |   amount   
---------+------------+--------------+---------------+--------------+-----------------+------------
     601 | 2026-09-01 | 4000         | Product sales | Revenue      |                 | -290737.44
     601 | 2026-09-01 | 4000         | Product sales | Revenue      |                 | -290737.44
```    

Treatment: Although it's very likely to be a duplicate revenue line, I'll confirm with the accountant. Confirmed with accounting and reversed with an equal and opposite entry (line 9003). GL revenue now ties to the sales subledger.


```sql
INSERT INTO gl_actuals (line_id, month, account_id, department_id, product_id, amount) VALUES
    (9003, DATE '2026-09-01', 1, NULL, 6, 290737.44);   -- Dr Product sales, reverses duplicate of line 601
```

The duplicate is a credit entry, so the reversal would be a debit entry. Revenue drops back to the correct amount.

```
 line_id |   month    | account_code | product_id |   amount
---------+------------+--------------+------------+------------
     601 | 2026-09-01 | 4000         |          6 | -290737.44   -- original
     601 | 2026-09-01 | 4000         |          6 | -290737.44   -- duplicate
    9003 | 2026-09-01 | 4000         |          6 |  290737.44   -- reversal
```    

## DQ4. Lines that can't be placed

A few GL lines seem to have nowhere to go on the P&L.
- Task: find lines missing a mandatory field: line_id, month, account or amount
- Decide: can any of them go on the P&L as they are?

```sql
SELECT
    g.line_id,
    g.month,
    a.account_code,
    a.account_name,
    d.department_name,
    g.amount
FROM gl_actuals AS g
LEFT JOIN accounts AS a
    ON g.account_id = a.account_id
LEFT JOIN departments AS d
    ON g.department_id = d.department_id
WHERE g.line_id IS NULL
    OR g.month IS NULL
    OR g.account_id IS NULL
    OR g.amount IS NULL;
```

```
 line_id |   month    | account_code | account_name |     department_name      |  amount  
---------+------------+--------------+--------------+--------------------------+----------
     632 | 2026-07-01 |              |              | General & Administrative | 12345.67
     633 | 2026-09-01 | 6400         | Travel       | Engineering              |         
```

Neither line can go on the P&L as it is:
- Line 632 has an amount but no account, so there's no P&L line to put it on.
- Line 633 is September travel for Engineering, but with no amount, there's nothing to report.

I used LEFT JOINs here on purpose. An INNER JOIN to `accounts` would drop line 632, the exact row I'm looking for.

Treatment: Put both on hold and ask the accountant to complete the missing fields in Oracle. They'll come through in the next extract once fixed.

## DQ5. The account nobody knows

Your P&L total doesn't match the GL total, and the gap sits in Engineering in August.
- Task: find account, department or product codes that don't exist in their master tables
- Decide: exclude them, or show them on the P&L until finance maps them?

An anti-join finds rows with no match: LEFT JOIN to the master table, then keep the rows where the master side is NULL.

```sql
SELECT
    g.line_id,
    g.month,
    g.account_id,
    d.department_name,
    g.amount
FROM gl_actuals AS g
LEFT JOIN accounts AS a
    ON g.account_id = a.account_id
LEFT JOIN departments AS d
    ON g.department_id = d.department_id
WHERE g.account_id IS NOT NULL
    AND a.account_id IS NULL;
```

```
 line_id |   month    | account_id | department_name |  amount  
---------+------------+------------+-----------------+----------
     634 | 2026-08-01 |         99 | Engineering     | 18500.00
```

`g.account_id IS NOT NULL` keeps out line 632 from DQ4. That line has no account at all, which is a different problem from having an account we don't recognise. The same check on departments and products returned no rows.

Account 99 isn't in the chart of accounts, so this RM18,500 falls off any P&L built with an INNER JOIN. That's the gap between the P&L and the GL total.

Treatment: Finance confirmed account 99 was created for software subscriptions but never added to the account mapping. I added it to the chart of accounts as 6700, under Other operating expenses:

```sql
INSERT INTO accounts (account_id, account_code, account_name, account_type, fs_line, fs_sort_order) VALUES
    (99, '6700', 'Software subscriptions', 'Opex', 'Other operating expenses', 70);
```

```
 line_id |   month    | account_code |      account_name      |         fs_line          | department_name |  amount  
---------+------------+--------------+------------------------+--------------------------+-----------------+----------
     634 | 2026-08-01 | 6700         | Software subscriptions | Other operating expenses | Engineering     | 18500.00
```

In practice, the finance systems team would update the account mapping.

## DQ6. The June spike

Your manager glances at the monthly trend and asks whether June marketing is a mistake.
- Task: find any account whose monthly total moved more than 50% from the prior month
- Decide: error or real? (The Marketing head confirms a trade show in June.)

```sql
WITH monthly AS (
    SELECT
        g.month,
        a.account_code,
        a.account_name,
        SUM(g.amount) AS total
    FROM gl_actuals AS g
    INNER JOIN accounts AS a
        ON g.account_id = a.account_id
    WHERE g.month < '2026-10-01'
        AND g.amount IS NOT NULL
    GROUP BY g.month, a.account_code, a.account_name
),
compared AS (
    SELECT
        *,
        LAG(total) OVER (PARTITION BY account_code ORDER BY month) AS prior_month
    FROM monthly
)

SELECT
    month,
    account_code,
    account_name,
    ROUND(prior_month, 0) AS prior_month,
    ROUND(total, 0) AS this_month,
    ROUND((total - prior_month) / ABS(prior_month) * 100, 1) AS pct_change
FROM compared
WHERE ABS(total - prior_month) / ABS(prior_month) > 0.5
ORDER BY month, account_code;
```

```
   month    | account_code | account_name | prior_month | this_month | pct_change 
------------+--------------+--------------+-------------+------------+------------
 2026-06-01 | 6600         | Marketing    |       83141 |     270000 |      224.8
 2026-07-01 | 6600         | Marketing    |      270000 |      87944 |      -67.4
```

`LAG` brings in the previous month's total for the same account, so each month can be compared with the one before. I divide by `ABS(prior_month)` because revenue is stored as negative, which would otherwise flip the sign of the % change.

Marketing jumped about 225% in June and dropped back in July. A one-month spike that returns to normal looks like a one-off event rather than an error.

Treatment: No change. The Marketing head confirmed a trade show in June. A flag like this is a question, not proof of an error, and I'll mention the trade show in the commentary so it doesn't distort the trend.

## DQ7. Revenue that doesn't tie

The sales team's September revenue report is lower than the GL by about RM0.3m.
- Task: reconcile GL revenue (account 4000) to sales_volume by month and find which month is out
- Decide: which earlier issue explains the gap?

```sql
WITH gl AS (
    SELECT
        month,
        -SUM(amount) AS gl_revenue
    FROM gl_actuals
    WHERE account_id = 1                  -- 4000 Product sales
        AND month < '2026-10-01'
    GROUP BY month
),
sv AS (
    SELECT
        month,
        SUM(actual_revenue) AS sales_revenue
    FROM sales_volume
    WHERE actual_revenue IS NOT NULL
    GROUP BY month
)

SELECT
    sv.month,
    gl.gl_revenue,
    sv.sales_revenue,
    gl.gl_revenue - sv.sales_revenue AS difference
FROM sv
LEFT JOIN gl
    ON gl.month = sv.month
WHERE gl.gl_revenue IS DISTINCT FROM sv.sales_revenue;
```

```
   month    | gl_revenue | sales_revenue | difference 
------------+------------+---------------+------------
 2026-09-01 | 8501409.13 |    8210671.69 |  290737.44
```

Only September is out, and the difference is exactly RM290,737.44: the duplicate revenue line from DQ3. The two checks confirm each other.

`-SUM(amount)` flips revenue back to positive so it can be compared with the sales report. `IS DISTINCT FROM` works like `<>` but also catches a month that's missing on one side.

Treatment: No separate adjustment needed. After the DQ3 reversal, GL revenue ties to the sales subledger in every month and this query returns no rows.

## Wrap-up

The rows on hold go into `gl_exceptions` with a reason, and everything else into `gl_actuals_clean`. Every later question reads from `gl_actuals_clean`.

| Check | Issue found | Rows | Treatment |
| --- | --- | --- | --- |
| DQ1 Missing department | Aug travel (RM26,679) with no cost center | 1 | Reclassed to Sales & Marketing (lines 9001–9002) |
| DQ2 Future date | Oct professional fees (RM15,000) in a Sep extract | 1 | On hold, confirming with accounting |
| DQ3 Duplicate | Sep CON-200 revenue (RM290,737) loaded twice | 1 | Reversed (line 9003) |
| DQ4 Missing mandatory field | One line with no account, one with no amount | 2 | On hold, accounting to complete |
| DQ5 Unmapped account | Account 99 (RM18,500) not in the chart of accounts | 1 | Mapped to 6700 Software subscriptions |
| DQ6 Month-over-month spike | June marketing ~3x normal | — | No change: genuine trade show |
| DQ7 Revenue reconciliation | Sep GL revenue RM290,737 above sales subledger | — | Explained by DQ3, ties after the reversal |

635 rows loaded, 3 put on hold (DQ2 and DQ4), and 632 used for analysis, plus the three adjusting entries.
