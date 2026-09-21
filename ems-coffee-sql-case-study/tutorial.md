# ☕️ Ems Coffee SQL Case Study

## Overview

Ems Coffee is a small café running a customer membership program. This case study has 3 tables: 
- `orders` (every transaction - who bought what, when, and how many)
- `menu` (item names and prices)
- `customers` (who's joined the membership program and when their membership started and ended, if at all). 

The questions are grouped into 3 tiers each building on the last:

- Core (Q1-7) the fundamentals: aggregate functions (COUNT, SUM, AVG), joins across tables, CASE statements for segmentation, and an introduction to window functions.
- Bonus (Q8-12) a step-up: CTEs, DENSE_RANK() with PARTITION BY, and reasoning about dates relative to a moving window — was a given order placed before, during, or after a customer's membership.
- Advanced (Q13-15) techniques used in real analytics work: NTILE() for percentile-based customer segmentation (RFM), cohort-based retention analysis, and LAG() for period-over-period trend comparisons.

If you'd like to practice rather than just read, try writing your own query for each question before checking the SQL and commentary underneath it, that's how this case study was actually built. 

***

All prices and revenue figures in this dataset are in Malaysian Ringgit (RM).

Definitions used throughout:

- "Orders" = distinct `order_id` count (an order can only ever contain one item; `quantity` captures multiple units of that same item, not multiple different items).
- "Member" = active membership at the time of a given order (`order_date` between `membership_start_date` and `membership_end_date` or ongoing if `membership_end_date` is NULL).

## Core Questions

1. [Orders & Revenue Overview](#1-orders--revenue-overview): How busy was the café — how many orders did we serve and how much revenue did we bring in? Return total orders and total revenue.
2. [Customer Loyalty Segments](#2-customer-loyalty-segments): Which customers keep coming back? Categorise customers with more than 6 orders as 'regulars', exactly 1 order as 'one-time', and everyone else as 'occasional'. Return customer ID, total orders, and visit frequency category, sorted by highest orders.
3. [Popularity vs. Profitability](#3-popularity-vs-profitability): What are customers actually drinking, and which of those drinks are the real money-makers? Return coffee name, total quantity sold, percentage of total volume, total revenue, and percentage of total revenue so it's clear whether the most popular item is also the most profitable one.
4. [Peak Revenue Days](#4-peak-revenue-days): Are there peak days - which weekdays bring in the most revenue? Return weekday name and total revenue.
5. [Top Spending Customers](#5-top-spending-customers): Who are our best customers - which 10 customers spend the most overall? Return customer ID, total spent, percentage of total revenue, and spend rank, limited to the top 10.
6. [Membership Status Breakdown](#6-membership-status-breakdown): How many of our customers are currently members, lapsed, or never joined? Return membership status (active member, lapsed member, never joined) and customer count for each.
7. [Member vs. Non-Member Value](#7-member-vs-non-member-value): Are members actually valuable? For every order, work out whether that customer was a member or a non-member at the time of that specific order — not their current status. The same customer can land in both groups, depending on when each order happened relative to their membership dates. Return: status (member/non-member), number of customers, total orders, average orders per customer, total revenue, and average spend per order.

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

Are there peak days — which days of the week bring in the most revenue? Return day of the week, number of times that day occurred, total revenue, and average revenue per occurrence limited to the top 5 days by total revenue.

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
ORDER BY total_revenue DESC
LIMIT 5;
```

**✅ Result:**
| day_of_week | num_day_of_week | total_revenue | avg_revenue_per_day |
|-------------|------------------|----------------|----------------------|
| Monday      | 32               | 1546.70        | 48.33                |
| Wednesday   | 37               | 1485.20        | 40.14                |
| Friday      | 38               | 1416.10        | 37.27                |
| Sunday      | 33               | 1131.70        | 34.29                |
| Thursday    | 36               | 1094.30        | 30.40                |

**💡 Commentary:**
Monday stands out as the strongest day once you see how often each day occurs in the data. It only shows up 32 times over the 15-month period, fewer than Wednesday (37 days) or Friday (38 days), and yet it earns the highest average revenue per occurrence at RM 48.33, well ahead of Wednesday's RM 40.14 and Friday's RM 37.27. So, it's not topping the list because "Monday just happens more often", it's genuinely a stronger day.

Interestingly, Friday's the opposite story. It has the highest number of occurences, however a considerably lower average revenue per day at RM37.27, meaning its total is coming from frequency rather than average on its own.

Worth investigating into why Monday performs so well. It could be something specific like a nearby office's schedule or a regular promo since that's the kind of thing that can be replicated on other days too, instead of assuming Friday is the "best" day just because its total looks big.

### 5. Top Spending Customers

Who are our best customers — which 10 customers spend the most overall? Return customer ID, total spent, percentage of total revenue, and spend rank limited to the top 10.

```sql
SELECT
    orders.customer_id,
    SUM(orders.quantity*menu.price) AS total_spent,
    ROUND(100.0*SUM(orders.quantity*menu.price)/
    SUM(SUM(orders.quantity*menu.price)) OVER (),2) AS pct_of_revenue,
    RANK() OVER (ORDER BY SUM(orders.quantity*menu.price) DESC) AS spend_rank
FROM orders
INNER JOIN menu
    ON orders.menu_id = menu.menu_id
GROUP BY orders.customer_id
ORDER BY total_spent DESC
LIMIT 10;
```

**⚠️ Common Pitfall:**
It's tempting to think `RANK() OVER (ORDER BY SUM(orders.quantity*menu.price) DESC)` already sorts the output since it has `ORDER BY` built into it. It doesn't. The `ORDER BY` inside `RANK() OVER (...)` only controls how the rank numbers are assigned to each row. It doesn't control how the order rows are physically returned in. 

SQL only guarantees output order when you add an explicit `ORDER BY` at the end of the query. Without it, the rank values would still be correct, but row 1 (`spend_rank` = 1) might not print at the top of your result.

**✅ Result:**
| customer_id | total_spent | pct_of_revenue | spend_rank |
|-------------|-------------|-----------------|------------|
| 23          | 384.30      | 4.44            | 1          |
| 11          | 360.10      | 4.16            | 2          |
| 20          | 357.90      | 4.13            | 3          |
| 10          | 348.30      | 4.02            | 4          |
| 16          | 331.70      | 3.83            | 5          |
| 29          | 327.40      | 3.78            | 6          |
| 8           | 315.30      | 3.64            | 7          |
| 15          | 310.30      | 3.58            | 8          |
| 1           | 308.40      | 3.56            | 9          |
| 26          | 306.40      | 3.54            | 10         |

**💡 Commentary:**
The top 10 customers together account for roughly 38.7% of total revenue. No single customer stands out disproportionately - the gap between rank 1 (4.44%) and rank 10 (3.54%) is fairly narrow, so spending is fairly evenly spread even within this top tier rather than driven by one or two "whale" customers.
 
### 6. Membership Status Breakdown

How many of our customers are currently members, lapsed, or never joined? Return membership status (active member, lapsed member, never joined) and customer count for each.

How to read `membership_start_date` and `membership_end_date` together:

| membership_start_date | membership_end_date | status        |
|------------------------|----------------------|----------------|
| NULL                    | NULL                 | never joined   |
| has a date              | NULL                 | active member  |
| has a date              | has a date           | lapsed member  |

```sql
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
```

**✅ Result:**
| member_status  | member_count |
|----------------|-------------:|
| active member  | 14           |
| lapsed member  | 10           |
| never joined   | 16           |

**💡 Commentary:**
Out of 40 customers, 16 (40%) have never signed up for membership at all - the single largest group. Of those who joined, more customers are still active (14) than have lapsed (10), so membership retention looks healthy once someone signs up. The bigger opportunity is converting the 40% who've never joined in the first place.

### 7. Member vs. Non-Member Value

Are members *actually* valuable? 

For every order, work out whether the customer was a member or a non-member *at the time that specific order was placed* and not their current status. The same customer can land in both groups depending on when each order happened relative to their membership dates. 

Return status (member/non-member), number of customers, total orders, average orders per customer, total revenue, and average spend per order.

How to read `membership_start_date` and `membership_end_date` together:

| membership_start_date | membership_end_date | status        |
|------------------------|----------------------|----------------|
| NULL                    | NULL                 | never joined   |
| has a date              | NULL                 | active member  |
| has a date              | has a date           | lapsed member  |

```sql
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
```

**✅ Result:**
| status_at_order | num_of_customers | total_orders | avg_order_per_customer | total_revenue | avg_revenue_per_order |
|------------------|------------------:|-------------:|------------------------:|---------------:|------------------------:|
| member           | 24                | 205          | 8.54                   | 5227.60        | 25.50                   |
| non-member       | 40                | 195          | 4.88                    | 3433.80       | 17.61                   |

**💡 Commentary:**
Members generate more total revenue than non-members (RM5,227.60 vs. RM3,433.80) despite being far fewer of them — 24 members compared to 40 non-members. So the per-person gap is actually bigger than the totals alone suggest.

Breaking it down, that gap comes from 2 separate effects:
- members order about 75% more often per person (8.54 vs. 4.88 orders on average), and
- they spend about 45% more per order when they do (RM25.50 vs. RM17.61).

In accounting terms, this is essentially a volume-and-rate decomposition — the same logic as splitting a revenue variance into "how many transactions" vs. "value per transaction" rather than leaving it as one unexplained number.

- Members: 24 customers × 8.54 orders/customer × RM25.50/order ≈ RM5,226 (actual: RM5,227.60)
- Non-members: 40 customers × 4.88 orders/customer × RM17.61/order ≈ RM3,437 (actual: RM3,433.80)

To sum up: members visit more often *and* spend more each time. That combination is a stronger, more durable form of value than either effect alone would be.

***

## Bonus Questions

### 8. Customer's Usual Order

Does each customer have a "usual"? Return customer ID, drink name, number of times ordered, and rank showing all ties (via `DENSE_RANK()`), not just a single top pick limited to the first 5 customers by customer ID.

```sql
WITH ranked_data AS (
    SELECT
        customer_id,
        coffee_name,
        COUNT(order_id) AS coffee_count,
        DENSE_RANK() OVER (
            PARTITION BY customer_id 
            ORDER BY COUNT(order_id) DESC) AS coffee_rank
    FROM orders
    INNER JOIN menu
        ON orders.menu_id = menu.menu_id
    GROUP BY
        customer_id,
        coffee_name
)
SELECT
    customer_id,
    coffee_name,
    coffee_count,
    coffee_rank
FROM ranked_data
WHERE 
    coffee_rank = 1
    AND customer_id <= 5
ORDER BY customer_id;
```

**✅ Result:**
| customer_id | coffee_name  | coffee_count | coffee_rank |
|-------------|--------------|--------------|-------------|
| 1           | Caffe Latte  | 3            | 1           |
| 1           | Americano    | 3            | 1           |
| 2           | Affogato     | 2            | 1           |
| 2           | Matcha Latte | 2            | 1           |
| 2           | Cappuccino   | 2            | 1           |
| 3           | Mocha        | 4            | 1           |
| 4           | Mocha        | 3            | 1           |
| 4           | Affogato     | 3            | 1           |
| 5           | Dirty Chai   | 2            | 1           |
| 5           | Affogato     | 2            | 1           |

**💡 Commentary:**
Only customer 3 has a genuinely clear "usual" (Mocha, ordered 4 times with no tie). Everyone else here is tied between 2-3 drinks.

So, for 4 of these 5 customers, "does each customer have a usual?" is really a "no, they have a rotation" which is exactly why showing ties via `DENSE_RANK()` mattered here. If we're to use a query that just grabbed a single top row per customer, say via `ROW_NUMBER()`, we would have arbitrarily picked one drink at random for each of these customers and presented it as their "usual", erroneously overstating how much loyalty any single drink actually has.

One thing worth a mention - Affogato consistently showed up in 3 of these 5 customers' tied top spots (2, 4, and 5) which is worth checking later whether that holds up across the full 40 customers since a drink that keeps appearing as a joint-favourite says something different about its popularity than one drink that's a lot of people's single go-to.

### 9. Time to Convert

How long does it typically take a customer to convert into a member? Return customer ID, first order date, membership start date, days to convert, and the average days-to-convert across all members.

```sql
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
GROUP BY customers.customer_id, membership_start_date
ORDER BY customers.customer_id;
```

**✅ Result:**
| customer_id | first_order_date | membership_start_date | days_to_convert | avg_days_to_convert |
|-------------|-------------------|-------------------------|------------------:|-----------------------:|
| 1           | 2025-01-01        | 2025-01-05              | 4                | 35.92                  |
| 3           | 2025-01-01        | 2025-02-10              | 40               | 35.92                  |
| 4           | 2025-01-15        | 2025-03-01              | 45               | 35.92                  |
| 5           | 2025-01-01        | 2025-01-20              | 19               | 35.92                  |
| 7           | 2025-01-01        | 2025-02-15              | 45               | 35.92                  |

**💡 Commentary:**
Conversion time is quite variable person-to-person in this sample from as fast as 4 days (customer 1) to as long as 45 days (customers 4 and 7) averaging around 36 days overall. 

Worth investigating further whether the average conversion days of 36 days represent the entire data or was pulled up by a select few customers' days to convert. 

### 10. Post-Lapse Drop-Off

When a customer's membership lapses, does their ordering drop off afterward? Return customer ID, orders per month while an active member, and orders per month after lapsing.

```sql

```

**✅ Result:**

**💡 Commentary:**

### 11. Tenure vs. Spend

Do long-tenured members spend more than newer members? Return tenure cohort (grouped by membership start month), number of customers, and average total spend per customer.

```sql

```

**✅ Result:**

**💡 Commentary:**

***

## Advanced Questions

### 12. RFM Customer Segmentation

Which customers are most valuable when you weigh how recently, how often, and how much they spend — not spend alone? For each customer, calculate recency (days since their last order), frequency (total orders), and monetary value (total spend), then score each dimension into quartiles using NTILE(4). Return customer ID, recency, frequency, monetary value, and the three quartile scores.

```sql

```

**✅ Result:**

**💡 Commentary:**

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

