-- Which product families drove the revenue miss? Return product family, Q3 actual revenue, budget revenue, variance (RM) and variance %, sorted by the most negative variance first.

WITH revenue_actuals AS (
    SELECT
        p.product_family,
        -SUM(g.amount) AS actual_revenue
    FROM gl_actuals_clean AS g
    INNER JOIN accounts AS a
        ON g.account_id = a.account_id
    INNER JOIN products AS p
        ON g.product_id = p.product_id
    WHERE a.account_type = 'Revenue'
        AND (month >= '2026-07-01' AND month <= '2026-09-30')
    GROUP BY p.product_family
)
, revenue_budget AS (
    SELECT
        p.product_family,
        -SUM(b.amount) AS budget_revenue
    FROM gl_budget AS b
    INNER JOIN accounts AS a
        ON b.account_id = a.account_id
    INNER JOIN products AS p
        ON b.product_id = p.product_id
    WHERE a.account_type = 'Revenue'
        AND (month >= '2026-07-01' AND month <= '2026-09-30')
    GROUP BY p.product_family
)

SELECT 
    ra.product_family,
    ra.actual_revenue,
    rb.budget_revenue,
    ra.actual_revenue - rb.budget_revenue AS variance,
    ROUND(100.0 * ((ra.actual_revenue - rb.budget_revenue)/rb.budget_revenue),1) AS variance_pct
FROM revenue_actuals AS ra
INNER JOIN revenue_budget AS rb
    ON ra.product_family = rb.product_family
ORDER BY variance ASC;

