-- Q12: Month-over-Month Revenue Growth

WITH revenue_data AS (
    SELECT
        TO_CHAR(order_date, 'YYYY-MM') AS mth_yr,
        SUM(quantity * price) AS total_revenue
    FROM orders
    INNER JOIN menu
        ON orders.menu_id = menu.menu_id
    WHERE order_date < '2026-01-01'
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
, lag_data AS (
    SELECT
        mth_yr,
        total_revenue,
        LAG(total_revenue) OVER (ORDER BY mth_yr) AS prev_mth_revenue
    FROM revenue_data
)

SELECT
	mth_yr,
    total_revenue AS current_mth_revenue,
    LAG(total_revenue) OVER (ORDER BY mth_yr) AS prev_mth_revenue,
    ROUND(100.0 * (total_revenue - prev_mth_revenue)/prev_mth_revenue,2) AS pct_change 
FROM lag_data
ORDER BY mth_yr;
