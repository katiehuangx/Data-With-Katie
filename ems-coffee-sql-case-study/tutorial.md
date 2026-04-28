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


### 2. Which customers keep coming back to Ems Coffee? Categorise customers with more than 6 orders as ‘regulars’, customers with only 1 order as 'one-time' and everyone else as 'occasional'. Return the customer ID, total orders and visit frequency sorted by the highest orders.

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
ORDER BY total_orders DESC;
```

✅ Expected result:

The first 3 rows: 
| customer_id 	| total_orders 	| visit_frequency 	|
|-------------	|--------------	|-----------------	|
| 8           	| 10           	| regular         	|
| 14          	| 9            	| regular         	|
| 25          	| 8            	| regular         	|

</details>


### 3. What are customers actually drinking — which items are ordered the most? Return the coffee name and order count.

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT
	coffee_name,
    SUM(quantity) AS order_count
FROM orders
INNER JOIN menu
	ON orders.menu_id = menu.menu_id
GROUP BY coffee_name
ORDER BY order_count DESC;
```

✅ Expected result:
| coffee_name  	| order_count 	|
|--------------	|-------------	|
| Matcha Latte 	| 35          	|
| Mocha        	| 33          	|
| Americano    	| 31          	|

</details>

### 4. Are there peak days — which days bring in the most revenue?

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:


</details>

### 6. Who are our best customers — which customers spend the most overall?

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:


</details>

### 7. On average, how much does a customer spend each time they order?

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:


</details>

### 8. Does each customer have a “usual” — what’s the most frequently ordered drink per customer?

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:


</details>

### 9. Are there bulk buyers — how many orders have unusually large quantities?


<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:


</details>

### 10. Which drinks are our money-makers — not just popular, but generating the most revenue?

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:


</details>

### 11. How many of our customers are currently members, and how many have dropped off or never joined?

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:


</details>

### 12. Are members actually valuable — how much revenue comes from members vs non-members?

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:


</details>

### 13. Do members spend more when they order, or is it about the same?

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:


</details>

### 14. Do members come back more often than non-members?

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:


</details>

### 15. Does membership change behaviour — do customers order more after becoming members?

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:


</details>

### 16. How long does it usually take for a customer to “convert” into a member?

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:


</details>

### 17. When customers stop being members, do they slowly stop ordering too?

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:


</details>

### 18. Who are the true VIPs — our top 5 highest-spending customers?

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:


</details>

### 19. Are we relying too much on a few customers — how much revenue comes from our top 20%?

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:


</details>

### 20. Do we have a retention problem — how many customers only ordered once and never came back?

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:


</details>

### 21. Do early members behave differently — are long-time members more valuable than newer ones?

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:


</details>

