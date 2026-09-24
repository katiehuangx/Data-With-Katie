-- Q1: Orders & Revenue Overview

SELECT
    COUNT(DISTINCT orders.order_id) AS total_orders,
    SUM(orders.quantity * menu.price) AS total_revenue
FROM orders
INNER JOIN menu
    ON orders.menu_id = menu.menu_id;
