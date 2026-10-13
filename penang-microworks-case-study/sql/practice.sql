SELECT line_id, month, account_id, department_id, product_id, amount
FROM gl_actuals
WHERE month <= DATE '2026-09-01'      -- DQ2: nothing after the as-of month
    AND account_id IS NOT NULL        -- DQ4: needs an account
    AND amount IS NOT NULL;           -- DQ4: needs an amount

