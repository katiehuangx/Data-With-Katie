-- Q4: Peak Revenue Days

SELECT
    TO_CHAR(orders.order_date, 'Day') AS day_of_week,
    COUNT(DISTINCT orders.order_date) AS num_day_of_week,
    SUM(orders.quantity*menu.price) AS total_revenue,
    ROUND(SUM(orders.quantity*menu.price)/COUNT(DISTINCT orders.order_date),2) AS avg_revenue_per_day
FROM orders
INNER JOIN menu
    ON orders.menu_id = menu.menu_id
GROUP BY TO_CHAR(orders.order_date, 'Day')
ORDER BY total_revenue DESC
LIMIT 5;
