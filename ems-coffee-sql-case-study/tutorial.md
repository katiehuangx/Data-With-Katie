# ☕️ Ems Coffee

Definitions used throughout:

- "Orders" = distinct `order_id` count (an order can only ever contain one item; `quantity` captures multiple units of that same item, not multiple different items).
- "Member" = active membership at the time of a given order (`order_date` between `membership_start_date` and `membership_end_date` or ongoing if `membership_end_date` is NULL).

## 💡 Case Study Questions

**Core Questions**

1. How busy was the café — how many orders did we serve and how much revenue did we bring in? Return total orders and total revenue.
2. Which customers keep coming back? Categorise customers with more than 6 orders as 'regulars', exactly 1 order as 'one-time', and everyone else as 'occasional'. Return customer ID, total orders, and visit frequency category, sorted by highest orders.
3. What are customers actually drinking — which items sell the most by volume? Return coffee name and total quantity sold.
4. Are there peak days — which weekdays bring in the most revenue? Return weekday name and total revenue.
5. Who are our best customers — which customers spend the most overall? Return customer ID and total spent.
6. Which drinks are our money-makers — highest revenue generated (not just most popular)? Return coffee name and total revenue.
7. How many of our customers are currently members, lapsed, or never joined? Return counts by status.
8. Are members actually valuable? Compare total revenue, average spend per order, and order frequency between members and non-members, based on membership status at the time of each order.

**Bonus Questions**

9. On average, how much does a customer spend each time they order? Return customer ID and average spend per order, sorted by highest average.
10. Does each customer have a "usual"? Return each customer's most frequently ordered drink(s) — show all ties (DENSE_RANK() so tied drinks appear together).
11. Are there bulk buyers? Return orders with quantity ≥ 5.
12. Does membership change behaviour — do customers order more after becoming a member than before?
13. How long does it typically take a customer to convert into a member (first order → membership start date)?
14. When a customer's membership lapses, does their ordering drop off afterward?
15. Do long-tenured members spend more than newer members? (Cohort by membership_start_date, compare spend.)

## ✅ Case Study Answers

#### 1. How busy was the café — how many orders did we serve and how much revenue did we bring in? Return total orders and total revenue.

```sql
SELECT
    COUNT(DISTINCT orders.order_id) AS total_orders,
    SUM(orders.quantity * menu.price) AS total_revenue
FROM orders
INNER JOIN menu
	ON orders.menu_id = menu.menu_id;
```

✅ Expected result:
| total_orders | total_revenue |
|---|---|
| 438 | 9915.60 |

#### 2. Which customers keep coming back? Categorise customers with more than 6 orders as 'regulars', 1 order as 'one-time', and everyone else as 'occasional'. Return customer ID, total orders, and visit frequency category sorted by highest orders.

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

The first 5 rows: 
| customer_id 	| total_orders 	| visit_frequency 	|
|:-----------:	|:------------:	|:---------------:	|
| 6           	| 8            	| regular         	|
| 12          	| 7            	| regular         	|
| 3           	| 7            	| regular         	|
| 9           	| 6            	| occasional      	|
| 8           	| 6            	| occasional      	|


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
| Matcha Latte 	| 38         	|
| Hojicha Latte | 32          	|
| Espresso    	| 32          	|

</details>

### 4. Are there peak days — which days bring in the most revenue? Return the name of the weekday and total revenue.

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT
    TO_CHAR(orders.order_date, 'Day') AS day_of_week,
    SUM(orders.quantity*menu.price) AS total_revenue
FROM orders
INNER JOIN menu
	ON orders.menu_id = menu.menu_id
GROUP BY TO_CHAR(orders.order_date, 'Day')
ORDER BY total_revenue DESC;
```

✅ Expected result:

| day_of_week | total_revenue |
|-------------|---------------|
| Thursday    | 711.60        | 
| Friday      | 630.40        |
| Wednesday   | 616.20        |

</details>

### 5. Who are our best customers — which customers spend the most overall? Return the customer ID and total spent.

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT
    orders.customer_id,
    SUM(orders.quantity*menu.price) AS total_spent
FROM orders
INNER JOIN menu
	ON orders.menu_id = menu.menu_id
GROUP BY orders.customer_id
ORDER BY total_spent DESC;
```

✅ Expected result:

| day_of_week | total_revenue |  
|-------------|---------------|
| Thursday    | 711.60        |   
| Friday      | 630.40        |   
| Wednesday   | 616.20        |   

</details>


### 6. On average, how much does a customer spend each time they order? Return the customer ID with the average spent ordered by the highest average spent.

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT
    orders.customer_id,
    ROUND(
        SUM(orders.quantity*menu.price)
        /COUNT(orders.order_id)
        ,2) AS avg_spent
FROM orders
INNER JOIN menu
	ON orders.menu_id = menu.menu_id
GROUP BY orders.customer_id
ORDER BY avg_spent DESC;
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

