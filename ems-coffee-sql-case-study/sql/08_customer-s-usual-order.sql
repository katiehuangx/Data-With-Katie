-- Q8: Customer's Usual Order

WITH ranked_data AS (
    SELECT
        customer_id,
        coffee_name,
        COUNT(order_id) AS coffee_count,
        DENSE_RANK() OVER (
            PARTITION BY customer_id 
            ORDER BY COUNT(order_id) DESC) AS coffee_rank
    FROM orders
    INNER JOIN menu
        ON orders.menu_id = menu.menu_id
    GROUP BY
        customer_id,
        coffee_name
)
SELECT
    customer_id,
    coffee_name,
    coffee_count,
    coffee_rank
FROM ranked_data
WHERE 
    coffee_rank = 1
    AND customer_id <= 5
ORDER BY customer_id;
