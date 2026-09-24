-- Q11: RFM Customer Segmentation

WITH customer_metrics AS (
    SELECT 
        customer_id,
        MAX(order_date) AS last_order_date,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(quantity * price) AS monetary
    FROM orders
    INNER JOIN menu
        ON orders.menu_id = menu.menu_id
    GROUP BY customer_id
)
, snapshot_data AS(
    SELECT MAX(order_date) AS snapshot_date
    FROM orders
)

SELECT 
	customer_id,
    snapshot_date - last_order_date AS recency,
    frequency,
    monetary,
	NTILE(4) OVER (ORDER BY snapshot_date - last_order_date DESC) AS recency_score,
    NTILE(4) OVER (ORDER BY frequency ASC) AS frequency_score,
    NTILE(4) OVER (ORDER BY monetary ASC) AS monetary_score
FROM customer_metrics
CROSS JOIN snapshot_data
ORDER BY customer_id;

-- ---

WITH customer_metrics AS (
SELECT 
	customer_id,
    MAX(order_date) AS last_order_date,
    COUNT(DISTINCT order_id) AS frequency,
    SUM(quantity * price) AS monetary
FROM orders
INNER JOIN menu
    ON orders.menu_id = menu.menu_id
GROUP BY customer_id
)
, snapshot_data AS(
SELECT MAX(order_date) AS snapshot_date
FROM orders
)
, scores AS (
SELECT 
	customer_id,
    snapshot_date - last_order_date AS recency,
    frequency,
    monetary,
	NTILE(4) OVER (ORDER BY snapshot_date - last_order_date DESC) AS recency_score,
    NTILE(4) OVER (ORDER BY frequency ASC) AS frequency_score,
    NTILE(4) OVER (ORDER BY monetary ASC) AS monetary_score
FROM customer_metrics
CROSS JOIN snapshot_data
)

SELECT *
FROM scores
WHERE 
	recency_score = 4
    AND frequency_score = 4
    AND monetary_score = 4
ORDER BY customer_id;
