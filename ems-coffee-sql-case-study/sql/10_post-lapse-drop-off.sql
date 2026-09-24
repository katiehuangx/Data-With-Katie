-- Q10: Post-Lapse Drop-Off

WITH orders_data AS (
    SELECT
        orders.customer_id,
        customers.membership_start_date,
        customers.membership_end_date,
        COUNT(
            CASE WHEN orders.order_date BETWEEN customers.membership_start_date AND customers.membership_end_date THEN 1 END
            ) AS active_orders,
        COUNT(
            CASE WHEN orders.order_date > customers.membership_end_date THEN 1 END
            ) AS lapsed_orders
    FROM orders
    INNER JOIN customers 
        ON orders.customer_id = customers.customer_id
    WHERE customers.membership_end_date IS NOT NULL
    GROUP BY 
        orders.customer_id,
        customers.membership_start_date,
        customers.membership_end_date
)
, snapshot_data AS (
    SELECT MAX(order_date) AS snapshot_date
    FROM orders
)

SELECT
	customer_id,
    active_orders,
    ROUND(
        active_orders/
        NULLIF((membership_end_date - membership_start_date) / 30.0, 0)
        ,2) AS active_orders_per_month,
    lapsed_orders,
    ROUND(
        lapsed_orders/
        NULLIF((snapshot_date - membership_end_date) / 30.0, 0)
        ,2) AS lapsed_orders_per_month
FROM orders_data
CROSS JOIN snapshot_data
ORDER BY customer_id;
