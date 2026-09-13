# ☕️ Ems Coffee SQL Case Study

## Overview

Definitions used throughout:

- "Orders" = distinct `order_id` count (an order can only ever contain one item; `quantity` captures multiple units of that same item, not multiple different items).
- "Member" = active membership at the time of a given order (`order_date` between `membership_start_date` and `membership_end_date` or ongoing if `membership_end_date` is NULL).

## Core Questions

1. [Orders & Revenue Overview](#1-orders--revenue-overview): How busy was the café — how many orders did we serve and how much revenue did we bring in? Return total orders and total revenue.
2. [Customer Loyalty Segments](#2-customer-loyalty-segments): Which customers keep coming back? Categorise customers with more than 6 orders as 'regulars', exactly 1 order as 'one-time', and everyone else as 'occasional'. Return customer ID, total orders, and visit frequency category, sorted by highest orders.
3. [Popularity vs. Profitability](#3-popularity-vs-profitability): What are customers actually drinking, and which of those drinks are the real money-makers? Return coffee name, total quantity sold, percentage of total volume, total revenue, and percentage of total revenue — so it's clear whether the most popular item is also the most profitable one.
4. [Peak Revenue Days](#4-peak-revenue-days): Are there peak days — which weekdays bring in the most revenue? Return weekday name and total revenue.
5. [Top Spending Customers](#5-top-spending-customers): Who are our best customers — which customers spend the most overall? Return customer ID and total spent.
6. [Membership Status Breakdown](#6-membership-status-breakdown): How many of our customers are currently members, lapsed, or never joined? Return counts by status.
7. [Member vs. Non-Member Value](#7-member-vs-non-member-value): Are members actually valuable? Compare total revenue, average spend per order, and order frequency between members and non-members, based on membership status at the time of each order.

## Bonus Questions

8. [Average Order Value](#8-average-order-value): On average, how much does a customer spend each time they order? Return customer ID and average spend per order, sorted by highest average.
9. [Customer's Usual Order](#9-customers-usual-order): Does each customer have a "usual"? Return each customer's most frequently ordered drink(s) — show all ties (`DENSE_RANK()` so tied drinks appear together).
10. [Bulk Order Detection](#10-bulk-order-detection): Are there bulk buyers? Return orders with quantity ≥ 5.
11. [Membership Behaviour Shift](#11-membership-behaviour-shift): Does membership change behaviour — do customers order more after becoming a member than before?
12. [Time to Convert](#12-time-to-convert): How long does it typically take a customer to convert into a member (first order → membership start date)?
13. [Post-Lapse Drop-Off](#13-post-lapse-drop-off): When a customer's membership lapses, does their ordering drop off afterward?
14. [Tenure vs. Spend](#14-tenure-vs-spend): Do long-tenured members spend more than newer members? (Cohort by `membership_start_date`, compare spend.)

## Case Study Answers

### 1. Orders & Revenue Overview

How busy was the café — how many orders did we serve and how much revenue did we bring in? Return total orders and total revenue.

```sql
SELECT
    COUNT(DISTINCT orders.order_id) AS total_orders,
    SUM(orders.quantity * menu.price) AS total_revenue
FROM orders
INNER JOIN menu
	ON orders.menu_id = menu.menu_id;
```

**⚠️ Common Pitfall:**
It's tempting to use `COUNT(orders.order_id)` instead of `COUNT(DISTINCT orders.order_id)` to count the number of orders. However, since the primary key is `(order_id, menu_id)`, a single order could contain more than one item and therefore appear across multiple rows. Using `DISTINCT` ensures each order is counted once regardless of how many items it contains.

**✅ Result:**
| total_orders | total_revenue |
|---|---|
| 400 | 8661.40 |

**💡 Commentary:**
Ems Coffee served 400 orders for RM8,661.40 in revenue which is an average order value (AOV) of roughly RM . On its own, it's a one-line figure and we have yet to know whether that revenue is concentrated in a handful of customers or spread evenly which is what the customer segmentation in Q2 and Q5 will unpack. 

### 2. Customer Loyalty Segments

Which customers keep coming back? Categorise customers with more than 6 orders as 'regulars', exactly 1 order as 'one-time', and everyone else as 'occasional'. 

Return customer ID, total orders, and visit frequency category sorted by highest orders.

```sql
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
```

**✅ Result:**

The first 3 rows: 
| customer_id | total_orders | visit_frequency |
|---|---|---|
| 10 | 15 | regular |
| 3 | 14 | regular |
| 6 | 14 | regular |

**💡 Commentary:**
This groups customers into 3 tiers based on their visit frequency. It's great data if we're zooming into individual customers, but it doesn't tell us much from a business perspective. 

Let's retrieve some percentages to give the data some meaning that stakeholders will be interested in. 

Return visit frequency, count of customers, percentage of customers, total number of orders, and percentage of orders categorized by their visit frequency.

```sql
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
```

**✅ Result:**
| visit_frequency | num_customers | pct_of_customers | total_orders | pct_of_orders |
|---|---|---|---|---|
| regular | 30 | 75.00 | 365 | 91.25 |
| occasional | 7 | 17.50 | 32 | 8.00 |
| one-time | 3 | 7.50 | 3 | 0.75 |

**💡 Commentary:**
Regular customers make up 75% (30 out of 40 customers) of Ems Coffee's customers, but they're responsible for 91.25% of all orders. Occasional customers represent a modest 8% and one-time customers barely register at 0.75%. 

This confirms the earlier point with real numbers: almost the entire business runs on a small core of repeat customers, not a wide base of casual visitors.


### 3. Popularity vs. Profitability 

What are customers actually drinking and which of those drinks are the real money-makers? 

Return coffee name, total quantity sold, percentage of total volume, total revenue, and percentage of total revenue so it's clear whether the most popular item is also the most profitable one.

```sql
SELECT
    menu.coffee_name,
    SUM(orders.quantity) AS qty_sold,
    ROUND(100.0 * SUM(orders.quantity)/SUM(SUM(orders.quantity)) OVER (),2) AS pct_of_sold,
    SUM(orders.quantity*menu.price) AS total_revenue,
    ROUND(100.0 * SUM(orders.quantity*menu.price)/SUM(SUM(orders.quantity*menu.price)) OVER (),2) AS pct_of_revenue
FROM orders
INNER JOIN menu
    ON orders.menu_id = menu.menu_id
GROUP BY coffee_name
ORDER BY total_revenue DESC;
```

**✅ Result:**
| coffee_name | qty_sold | pct_of_sold | total_revenue | pct_of_revenue |
|---|---|---|---|---|
| Mocha | 74 | 10.82 | 1102.60 | 12.73 |
| Matcha Latte | 75 | 10.96 | 1042.50 | 12.04 |
| Dirty Chai | 65 | 9.50 | 1033.50 | 11.93 |
| Affogato | 73 | 10.67 | 941.70 | 10.87 |
| Hojicha Latte | 67 | 9.80 | 931.30 | 10.75 |

**💡 Commentary:**
Mocha edges out Matcha Latte for the top revenue spot (12.73% vs 12.04%) even though Matcha Latte actually sold slightly more units (75 vs 74) - a small, but clear example of volume and revenue not lining up perfectly. 

Dirty Chai is the more interesting case - it sells noticeably less volume than the top two (65 units vs 74 and 75), but still lands close behind them on revenue (11.93%) because it's priced higher per drink (RM15.90 vs RM14.90 and RM13.90). 

So, among these top five, the ranking by "most sold" and the ranking by "most profitable" aren't quite the same.

### 4. Peak Revenue Days

Are there peak days — which weekdays bring in the most revenue? Return weekday name and total revenue.

```sql
SELECT
    TO_CHAR(orders.order_date, 'Day') AS day_of_week,
    COUNT(DISTINCT orders.order_date) AS num_day_of_week,
    SUM(orders.quantity*menu.price) AS total_revenue,
    ROUND(SUM(orders.quantity*menu.price)/COUNT(DISTINCT orders.order_date),2) AS avg_revenue_per_day
FROM orders
INNER JOIN menu
	ON orders.menu_id = menu.menu_id
GROUP BY TO_CHAR(orders.order_date, 'Day')
ORDER BY total_revenue DESC;
```

**✅ Result:**
| day_of_week | num_day_of_week | total_revenue | avg_revenue_per_day |
|-------------|-----------------|----------------|----------------------|
| Wednesday   | 31              | 1495.90        | 48.25                |
| Friday      | 35              | 1492.30        | 42.64                |
| Thursday    | 27              | 1255.70        | 46.51                |
| Sunday      | 26              | 1237.10        | 47.58                |
| Monday      | 28              | 1160.00        | 41.43                |

**💡 Commentary:**
Wednesday is the genuine peak day at both total revenue (RM1,495.90) and average revenue per day (RM48.25), so there's no ambiguity there. 

Friday is more interesting because it ranks #2 at total revenue (RM1,492.30), however its average per day (RM42.64) is considerably lower than Thursday's (RM46.51) and Sunday's (RM47.58). Friday's total looks strong mainly because there were more Fridays (35 days) than Thursdays (27 days) or Sundays (26 days) in the data, not because each individual Friday brought in more money.

If Ems Coffee used the total revenue ranking alone to decide staffing or promotions, they'd likely overprioritize Friday over days that are actually stronger performers per occurrence.


### 5. Top Spending Customers

Who are our best customers — which customers spend the most overall? Return customer ID and total spent.

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

