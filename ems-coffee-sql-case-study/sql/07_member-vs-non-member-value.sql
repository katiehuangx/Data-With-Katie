-- Q7: Member vs. Non-Member Value

WITH customer_status AS (
    SELECT
        customers.customer_id,
  		orders.order_id,
  		orders.order_date,
		orders.quantity,
  		menu.price,
        CASE
        	WHEN order_date BETWEEN membership_start_date AND membership_end_date THEN 'member'
            WHEN membership_start_date IS NOT NULL AND membership_end_date IS NULL 
                AND order_date >= membership_start_date THEN 'member'
            ELSE 'non-member'
        END AS status_at_order
    FROM customers
  	INNER JOIN orders
  		ON customers.customer_id = orders.customer_id
	INNER JOIN menu
		ON orders.menu_id = menu.menu_id
)
  
SELECT 
    status_at_order,
	COUNT (DISTINCT customer_id) AS num_of_customers,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(COUNT(DISTINCT order_id)::NUMERIC/COUNT(DISTINCT customer_id),2) AS avg_order_per_customer,
    SUM(quantity * price) AS total_revenue,
    ROUND(SUM(quantity * price)/COUNT(DISTINCT order_id),2) AS avg_revenue_per_order
FROM customer_status
GROUP BY status_at_order;
