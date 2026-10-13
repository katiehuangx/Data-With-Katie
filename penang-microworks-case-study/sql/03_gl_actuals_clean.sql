-- =====================================================================
-- Clean GL: the table every analysis query reads from
-- Run after adjustments.sql:
--   psql penang_microworks -f sql/03_gl_actuals_clean.sql
--
-- gl_actuals already includes the adjusting entries (9001-9003), so the
-- only thing left to do is leave out the 3 lines on hold:
--   DQ2 line 631: future-dated (October), confirming with accounting
--   DQ4 line 632: no account; line 633: no amount
-- =====================================================================

CREATE OR REPLACE VIEW gl_actuals_clean AS
SELECT line_id, month, account_id, department_id, product_id, amount
FROM gl_actuals
WHERE month <= DATE '2026-09-01'      -- DQ2: nothing after the as-of month
    AND account_id IS NOT NULL        -- DQ4: needs an account
    AND amount IS NOT NULL;           -- DQ4: needs an amount


-- Check: rows loaded vs rows used (expect 638 loaded incl. 3 adjustments, 635 clean)
SELECT
    (SELECT COUNT(*) FROM gl_actuals)       AS rows_in_gl,
    (SELECT COUNT(*) FROM gl_actuals_clean) AS rows_clean;
