# Data Quality Checks: Issues found in the September 2026 GL extract

You've just received the September GL extract from the ERP. Before building the variance pack, you run your usual checks and hit seven issues. For each one: find the rows, decide the treatment, and note it for the README. Every bad row is either quarantined with a reason or kept and labelled, never silently dropped.

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

Accounting treatment: After confirming with the S&M manager, I reclassed the cost to Sales & Marketing with a journal entry in `sql/adjustments.sql` rather than editing the original line:
- Healthy accounting practice is to correct records with an adjusting entry, not by overwriting them 
- This is to ensure proper audit trail showing what changed and why.

```sql
-- Reclass journal: Aug travel from Unassigned to Sales & Marketing
INSERT INTO gl_actuals (line_id, month, account_id, department_id, product_id, amount) VALUES
    (9001, DATE '2026-08-01', 10, 3,    NULL,  26678.86),   -- Dr Travel, Sales & Marketing
    (9002, DATE '2026-08-01', 10, NULL, NULL, -26678.86);   -- Cr Travel, Unassigned
```

The double entry with original entry:

 line_id |   month    | account_code | account_type | department_id | product_id |   amount  | 
---------+------------+--------------+--------------+---------------+------------+-----------
     556 | 2026-08-01 | 6400         | Opex         |               |            |  26678.86 
    9001 | 2026-08-01 | 6400         | Opex         |             3 |            |  26678.86 
    9002 | 2026-08-01 | 6400         | Opex         |               |            | -26678.86 

556 is the original entry, 9001 the debit to Sales & Marketing, and 9002 the credit out of Unassigned. 

To check 
```sql
SELECT SUM(amount) AS journal_balance
FROM gl_actuals
WHERE line_id IN (9001, 9002);
```

Net effect of reclass:
 department_id |  amount  
---------------+----------
             3 | 26678.86 
               |     0.00 

The travel claims are now reflected under Sales & Marketing and the Unassigned lines (556 and 9002) cancel out to zero. Total OPEX is unchanged.

In practice, the accounting team would post this reclass in Oracle and it'll flow into the data warehouse at the next refresh.

## DQ2. Entries from the future

You're reporting as of September, but the extract seems to run past it.
• Your task: find any lines dated after September 2026
• Decide: can these be actuals? What would you ask the accountant who posted them?

## DQ3. The double-loaded batch
The ERP team mentions a September revenue upload was re-run after a timeout.
• Your task: find any line_id that appears more than once
• Decide: which copy do you keep, and what happens to the rest?

## DQ4. Lines that can't be placed
A few GL lines seem to have nowhere to go on the P&L.
• Your task: find lines missing a mandatory field: line_id, month, account or amount
• Decide: can any of them go on the P&L as they are?
DQ5. The account nobody knows
Your P&L total doesn't match the GL total, and the gap sits in Engineering in August.
• Your task: find account, department or product codes that don't exist in their master tables
• Decide: exclude them, or show them on the P&L until finance maps them?
DQ6. The June spike
Your manager glances at the monthly trend and asks whether June marketing is a mistake.
• Your task: find any account whose monthly total moved more than 50% from the prior month
• Decide: error or real? (The Marketing head confirms a trade show in June.)
DQ7. Revenue that doesn't tie
The sales team's September revenue report is lower than the GL by about RM0.3m.
• Your task: reconcile GL revenue (account 4000) to sales_volume by month and find which month is out
• Decide: which earlier issue explains the gap?
Wrap-up: build gl_exceptions (quarantined rows with a reason) and gl_actuals_clean (everything else), then a one-table summary of rows found and treatment per check. Every later question reads from gl_actuals_clean.
• Solution: sql/02_data_quality_checks.sql (same DQ1–DQ7 numbering)