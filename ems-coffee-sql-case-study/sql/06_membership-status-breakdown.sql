-- Q6: Membership Status Breakdown

WITH customer_status AS (
    SELECT
        customer_id,
        CASE
            WHEN membership_start_date IS NOT NULL AND membership_end_date IS NULL THEN 'active member'
            WHEN membership_start_date IS NULL AND membership_end_date IS NULL THEN 'never joined'
            ELSE 'lapsed member'
        END AS member_status
    FROM customers
)
  
SELECT 
    member_status,
    COUNT (DISTINCT customer_id) AS member_count
FROM customer_status
GROUP BY member_status;
