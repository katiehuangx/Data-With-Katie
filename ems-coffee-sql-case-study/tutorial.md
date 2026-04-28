# Ems Coffee

The `orders` data are in January 2026 only.

## Questions


## Let's Solve Them Together

### 1. How busy was the café — how many orders did we actually serve and how much money did the café bring in? Return the total orders and total revenue.

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT 
	COUNT(orders.order_id) AS total_orders,
    SUM(orders.quantity * menu.price) AS total_revenue
FROM orders
INNER JOIN menu
	ON orders.menu_id = menu.menu_id;
```

✅ Expected result:
| total_orders 	| total_revenue 	|
|--------------	|---------------	|
| 150          	| 3957.10       	|

</details>


### 2. Which customers keep coming back to Ems Coffee? Categorise customers with more than 6 orders as ‘regulars’, customers with only 1 order as 'one-time' and everyone else as 'occasional'. Return the customer ID, total orders and visit frequency. 

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT 
	customer_id,
    COUNT(order_id) AS total_orders,
    CASE
    	WHEN COUNT(order_id) > 6 THEN 'regular'
        WHEN COUNT(order_id) BETWEEN 2 AND 6  THEN 'occasional'
        ELSE 'one-time' 
    END AS visit_frequency
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC; -- optional
```

✅ Expected result:

The first 3 rows: 
| customer_id 	| total_orders 	| visit_frequency 	|
|-------------	|--------------	|-----------------	|
| 8           	| 10           	| regular         	|
| 14          	| 9            	| regular         	|
| 25          	| 8            	| regular         	|

</details>



### 4. What are customers actually drinking — which items are ordered the most?
### 5. Are there peak days — which days bring in the most revenue?
### 6. Who are our best customers — which customers spend the most overall?
### 7. On average, how much does a customer spend each time they order?
### 8. Does each customer have a “usual” — what’s the most frequently ordered drink per customer?
### 9. Are there bulk buyers — how many orders have unusually large quantities?
### 10. Which drinks are our money-makers — not just popular, but generating the most revenue?
### 11. How many of our customers are currently members, and how many have dropped off or never joined?
### 12. Are members actually valuable — how much revenue comes from members vs non-members?
### 13. Do members spend more when they order, or is it about the same?
### 14. Do members come back more often than non-members?
### 15. Does membership change behaviour — do customers order more after becoming members?
### 16. How long does it usually take for a customer to “convert” into a member?
### 17. When customers stop being members, do they slowly stop ordering too?
### 18. Who are the true VIPs — our top 5 highest-spending customers?
### 19. Are we relying too much on a few customers — how much revenue comes from our top 20%?
### 20. Do we have a retention problem — how many customers only ordered once and never came back?
### 21. Do early members behave differently — are long-time members more valuable than newer ones?

