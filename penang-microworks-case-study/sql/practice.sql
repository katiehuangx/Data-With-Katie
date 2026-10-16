WITH sensor_modules AS (
    SELECT 
        sv.product_id,
        p.product_code,
        p.product_name,
        p.product_family,
        SUM(sv.actual_units) AS total_actual_units,
        SUM(sv.actual_revenue) AS total_actual_revenue,
        SUM(sv.budget_units) AS total_budget_units,
        SUM(sv.budget_revenue) AS total_budget_revenue
    FROM sales_volume AS sv
    INNER JOIN products AS p
        ON sv.product_id = p.product_id
    WHERE (month >= '2026-07-01' AND month <= '2026-09-30')
        AND product_family = 'Power modules'
    GROUP BY 
        sv.product_id,
        p.product_code,
        p.product_name,
        p.product_family
)

SELECT 
    product_id,
    product_code,
    product_name,
    product_family,
    ROUND((total_actual_revenue/total_actual_units),2) AS act_price_unit,
    total_actual_units,
    total_actual_revenue,
    ROUND((total_budget_revenue/total_budget_units),2) AS budget_price_unit,
    total_budget_units,
    total_budget_revenue,
    ROUND(100.0*(total_actual_units - total_budget_units)/total_budget_units,2) AS unit_var_pct,
    ROUND(100.0*(total_actual_revenue - total_budget_revenue)/total_budget_revenue,2) AS revenue_var_pct
FROM sensor_modules AS sm;