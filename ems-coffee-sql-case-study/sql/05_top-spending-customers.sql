-- Q5: Top Spending Customers

SELECT
    orders.customer_id,
    SUM(orders.quantity*menu.price) AS total_spent,
    ROUND(100.0*SUM(orders.quantity*menu.price)/
    SUM(SUM(orders.quantity*menu.price)) OVER (),2) AS pct_of_revenue,
    RANK() OVER (ORDER BY SUM(orders.quantity*menu.price) DESC) AS spend_rank
FROM orders
INNER JOIN menu
    ON orders.menu_id = menu.menu_id
GROUP BY orders.customer_id
ORDER BY total_spent DESC
LIMIT 10;
