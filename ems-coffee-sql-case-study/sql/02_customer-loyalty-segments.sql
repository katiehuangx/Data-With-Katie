-- Q2: Customer Loyalty Segments

SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    CASE
        WHEN COUNT(DISTINCT order_id) > 6 THEN 'regular'
        WHEN COUNT(DISTINCT order_id) BETWEEN 2 AND 6 THEN 'occasional'
        ELSE 'one-time'
    END AS visit_frequency
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC;

-- ---

WITH customer_category AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders,
        CASE
            WHEN COUNT(DISTINCT order_id) > 6 THEN 'regular'
            WHEN COUNT(DISTINCT order_id) BETWEEN 2 AND 6 THEN 'occasional'
            ELSE 'one-time' 
        END AS visit_frequency
    FROM orders
    GROUP BY customer_id
)

SELECT 
    visit_frequency,
    COUNT(*) AS num_of_customers,
    ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER (),2) AS pct_of_customers,
    SUM(total_orders) AS total_orders,
    ROUND(100.0 * SUM(total_orders)/SUM(SUM(total_orders)) OVER (),2) AS pct_of_orders
FROM customer_category  
GROUP BY visit_frequency
ORDER BY pct_of_orders DESC;
