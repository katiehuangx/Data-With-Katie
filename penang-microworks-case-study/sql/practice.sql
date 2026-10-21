-- Which departments overspent in Q3? Return department name, actual opex, budget opex, variance (RM) and variance %, sorted by the biggest overspend first.

WITH actuals_opex AS (
SELECT 
    d.department_name,
    SUM(g.amount) AS actual_opex
FROM gl_actuals_clean AS g
INNER JOIN departments AS d
    ON g.department_id = d.department_id
INNER JOIN accounts AS a
    ON g.account_id = a.account_id
WHERE (g.month >= '2026-07-01' AND g.month <= '2026-09-30')
    AND a.account_type = 'Opex'
GROUP BY d.department_name
)
, budget_opex AS (
SELECT 
    d.department_name,
    SUM(b.amount) AS budget_opex
FROM gl_budget AS b
INNER JOIN departments AS d
    ON b.department_id = d.department_id
INNER JOIN accounts AS a
    ON b.account_id = a.account_id
WHERE (b.month >= '2026-07-01' AND b.month <= '2026-09-30')
    AND a.account_type = 'Opex'
GROUP BY d.department_name
)

SELECT
    a.department_name,
    actual_opex,
    budget_opex,
    budget_opex - actual_opex AS variance,
    ROUND(100.0*(budget_opex - actual_opex)/budget_opex,1) AS variance_pct
FROM actuals_opex AS a
INNER JOIN budget_opex AS b
    ON a.department_name = b.department_name
ORDER BY variance ASC;
