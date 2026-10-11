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

To check:
```sql
SELECT department_id, SUM(amount) AS amount
FROM gl_actuals
WHERE line_id IN (556, 9001, 9002)
GROUP BY department_id;
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

Task: Find any lines dated after September 2026.

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

Budgeted professional fees are RM48,000 a month, so the RM15,000 doesn't look like a budget line posted as actuals. It could be a genuine October invoice posted early, with more to come. It's hard to tell without confirming with the accountant.

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

Your task: Find any line_id that appears more than once.
Decide: Which copy do you keep and what happens to the rest?

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

Treatment: It looked very likely to be a duplicate revenue line, but I confirmed with accounting before touching it. I then reversed the extra copy with an equal and opposite entry (line 9003) in `sql/adjustments.sql`. GL revenue now ties to the sales subledger (see DQ7).

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

## DQ4. Lines that can't be assigned to the P&L.

A few GL lines seem to have nowhere to go on the P&L.

- Task: Find lines missing a mandatory field: line_id, month, account or amount
- Decide: Can any of the lines be reported in the P&L as they are?

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

Both lines are not ready to go on the P&L:
- Line 632 has an amount, but no account so there's no P&L line to assign it to.
- Line 633 is a September travel expense for Engineering, but with no amount, so there's nothing to report.

Treatment: Put both on hold and ask the accountant to complete the missing fields in Oracle. They'll come through in the next extract once fixed.

## DQ5. The account nobody knows

Your P&L total doesn't match the GL total and the gap sits in Engineering in August.
- Task: Find account, department or product codes that don't exist in the accounts, departments or products tables.
- Decide: Exclude them or show them on the P&L until finance maps them?

To find codes with no match, I used an anti-join: a `LEFT JOIN` from the GL to the accounts table, keeping only the rows where the accounts side came back `NULL`.

```sql
SELECT
    g.line_id,
    g.month,
    g.account_id AS gl_account_id,
    a.account_id AS account_account_id,
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
 line_id |   month    | gl_account_id | account_account_id | department_name |  amount  
---------+------------+---------------+--------------------+-----------------+----------
     634 | 2026-08-01 |            99 |                    | Engineering     | 18500.00
```

A few notes on the query:
- `a.account_id IS NULL` is the anti-join filter. It's only `NULL` when the `LEFT JOIN` found no matching account.
- `g.account_id IS NOT NULL` excludes lines where the account is blank in `account_account_id`. Here I only want accounts that are filled in but don't exist in the accounts table.

Account 99 isn't in our account mapping, so any P&L built with an INNER JOIN silently drops this RM18,500. That's the gap between the P&L and the GL total.

⚠️ How did this happen? 
- Oracle won't accept a posting to an account that doesn't exist, so the posting was valid. 
- The gap sits between Oracle and the reporting layer. Account 99 was set up in Oracle by the accounting team for software subscriptions, but it hadn't been added to the reporting account mapping that FP&A uses to build the P&L. In larger companies these are often different teams, so a new account can slip through if the handover is missed.

Treatment: After confirming with finance, I added account 99 to the account mapping as 6700 Software subscriptions under Other operating expenses. I didn't change the GL line itself since it was correct all along. Only the mapping was incomplete.

```sql
INSERT INTO accounts (account_id, account_code, account_name, account_type, fs_line, fs_sort_order) VALUES
    (99, '6700', 'Software subscriptions', 'Opex', 'Other operating expenses', 70);
```

I've re-run the check and it returns no rows, so every GL line maps to a known account:

```
 line_id | month | gl_account_id | account_account_id | department_name | amount 
---------+-------+---------------+--------------------+-----------------+--------
(0 rows)
```

I ran the same anti-join against `departments` and `products` and both came back with no rows, so account 99 is the only unknown code.

```sql
SELECT
    g.line_id,
    g.month,
    g.account_id,
    a.account_code,
    a.account_name,
    d.department_name,
    a.fs_line,
    g.amount
FROM gl_actuals AS g
LEFT JOIN accounts AS a
    ON g.account_id = a.account_id
LEFT JOIN departments AS d
    ON g.department_id = d.department_id
WHERE g.line_id = 634;
```

The line now lands in the P&L:

```
 line_id |   month    | account_id | account_code |      account_name      | department_name |         fs_line          |  amount  
---------+------------+------------+--------------+------------------------+-----------------+--------------------------+----------
     634 | 2026-08-01 |         99 | 6700         | Software subscriptions | Engineering     | Other operating expenses | 18500.00
```

## DQ6. The June spike

Your manager glances at the monthly trend and asks whether June marketing is a mistake.
- Task: Check whether Marketing's monthly total moved more than 50% from the prior month.
- Decide: Error or real? (The Marketing head confirms a trade show in June.)

```sql
WITH monthly_marketing AS (
    SELECT
        g.month,
        a.account_code,
        a.account_name,
        SUM(g.amount) AS total_amount
    FROM gl_actuals AS g
    INNER JOIN accounts AS a
        ON g.account_id = a.account_id
    WHERE g.month < '2026-10-01'
        AND a.account_name = 'Marketing'
    GROUP BY g.month, a.account_code, a.account_name
)
, monthly_change AS (
SELECT
    month,
    account_code,
    account_name,
    total_amount AS curr_mth_amount,
    LAG(total_amount) OVER (ORDER BY month) AS prev_mth_amount,
    total_amount - LAG(total_amount) OVER (ORDER BY month) AS mth_change
FROM monthly_marketing
)

SELECT
    month,
    account_name,
    prev_mth_amount,
    curr_mth_amount,
    ROUND(100.0 * mth_change/prev_mth_amount,2) AS pct_change
FROM monthly_change;
```

```
   month    | account_name | prev_mth_amount | curr_mth_amount | pct_change 
------------+--------------+-----------------+-----------------+------------
 2026-01-01 | Marketing    |                 |        83165.42 |           
 2026-02-01 | Marketing    |        83165.42 |        89977.26 |       8.19
 2026-03-01 | Marketing    |        89977.26 |        85016.02 |      -5.51
 2026-04-01 | Marketing    |        85016.02 |        90552.65 |       6.51
 2026-05-01 | Marketing    |        90552.65 |        83140.75 |      -8.19
 2026-06-01 | Marketing    |        83140.75 |       270000.00 |     224.75 -- June with >50% increase
 2026-07-01 | Marketing    |       270000.00 |        87944.02 |     -67.43
 2026-08-01 | Marketing    |        87944.02 |        88604.20 |       0.75
 2026-09-01 | Marketing    |        88604.20 |        84540.10 |      -4.59
```

Marketing jumped about 225% in June and dropped back in July. The one-month spike looks like a one-off event rather than an error.

Treatment: No change. The Marketing head confirmed a trade show in June. 

## DQ7 Revenue that doesn't tie

The sales team's September revenue report is lower than the GL by about RM0.3m.
- Task: Reconcile GL revenue (account 4000) to sales_volume by month and find which month is out.
- Decide: which earlier issue explains the gap?

```sql
WITH gl AS (
    SELECT
        g.month,
        -SUM(g.amount) AS gl_revenue
    FROM gl_actuals AS g
    WHERE g.account_id = 1                  -- 4000 Product sales
        AND g.month < '2026-10-01'
    GROUP BY g.month
)
, sv AS (
    SELECT 
        month,
        SUM(actual_revenue) AS sv_revenue
    FROM sales_volume AS sv
    WHERE month < '2026-10-01'
    GROUP BY month
)

SELECT
    gl.month,
    gl.gl_revenue,
    sv.sv_revenue AS sales_revenue,
    gl.gl_revenue - sv.sv_revenue AS difference
FROM gl
LEFT JOIN sv
    ON gl.month = sv.month
WHERE gl.gl_revenue IS DISTINCT FROM sv.sv_revenue;

```

```
   month    | gl_revenue | sales_revenue | difference 
------------+------------+---------------+------------
 2026-09-01 | 8501409.13 |    8210671.69 |  290737.44
```

Only September is out and the difference is exactly RM290,737.44: the duplicate revenue line from DQ3. The two checks confirm each other.

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
| DQ5 Unmapped account | Account 99 (RM18,500) not in the reporting account mapping | 1 | Mapped to 6700 Software subscriptions |
| DQ6 Month-over-month spike | June marketing ~3x normal | — | No change: genuine trade show |
| DQ7 Revenue reconciliation | Sep GL revenue RM290,737 above sales subledger | — | Explained by DQ3, ties after the reversal |

635 rows loaded, 3 put on hold (DQ2 and DQ4), and 632 used for analysis, plus the three adjusting entries.
