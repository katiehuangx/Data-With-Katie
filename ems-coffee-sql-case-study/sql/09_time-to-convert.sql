-- Q9: Time to Convert

SELECT
    customers.customer_id,
    MIN(order_date) AS first_order_date,
    membership_start_date,
    membership_start_date-MIN(order_date) AS days_to_convert,
	ROUND(AVG(membership_start_date-MIN(order_date)) OVER (),2) AS avg_days_to_convert
FROM orders
INNER JOIN customers
	ON orders.customer_id = customers.customer_id
WHERE membership_start_date IS NOT NULL
GROUP BY 
    customers.customer_id, 
    membership_start_date
ORDER BY customers.customer_id;
