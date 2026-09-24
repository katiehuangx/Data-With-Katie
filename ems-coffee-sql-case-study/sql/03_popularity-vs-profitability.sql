-- Q3: Popularity vs. Profitability

SELECT
    menu.coffee_name,
    SUM(orders.quantity) AS qty_sold,
    ROUND(100.0 * SUM(orders.quantity)/SUM(SUM(orders.quantity)) OVER (),2) AS pct_of_sold,
    SUM(orders.quantity*menu.price) AS total_revenue,
    ROUND(100.0 * SUM(orders.quantity*menu.price)/SUM(SUM(orders.quantity*menu.price)) OVER (),2) AS pct_of_revenue
FROM orders
INNER JOIN menu
    ON orders.menu_id = menu.menu_id
GROUP BY coffee_name
ORDER BY total_revenue DESC;
