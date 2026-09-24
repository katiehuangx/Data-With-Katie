# ☕️ Ems Coffee SQL Case Study

## Table of Contents

- [Overview](#overview)
- [Core Questions](#core-questions)
- [Advanced Questions](#advanced-questions)
- [Case Study Solution](#case-study-solution)

## Overview

Ems Coffee is a small café running a customer membership program. This case study has 3 tables: 
- `orders` (every transaction - who bought what, when, and how many)
- `menu` (item names and prices)
- `customers` (who's joined the membership program and when their membership started and ended, if at all). 

Questions are grouped into two tiers — Core (fundamentals) and Advanced (window functions, CTEs, and more complex date reasoning). See the [README](./README.md) for the full technique breakdown and the approach behind this project.

**‼️ One thing worth saying upfront:** 
The SQL solution for each question is one way to solve it, but it's not the only way. There's usually more than one reasonable solution to the same answer: a different join, a CTE instead of a subquery, a different window function, so if your query looks nothing like mine, but outputs the same result, that's not wrong, it's just a different call. 

Use your own judgement 💡 for how to structure and present your solution, as long as the gist of the result matches.

## How this was built

*(See the [README](./README.md) for more on the approach — Claude helped draft and troubleshoot, but the verification is mine.)*

2 real issues surfaced along the way: a `GROUP BY` granularity bug in Q10 that silently collapsed the results to one row per order instead of one row per customer and a data-generation artifact in Q9 where exactly half of converted members (12 of 24) hit an identical, suspiciously round 45-day conversion time - a flaw in how the practice data was generated, not a real behavioural pattern.

***

All prices and revenue figures in this dataset are in Malaysian Ringgit (RM).

Definitions used throughout:

- "Orders" = distinct `order_id` count (an order can only ever contain one item; `quantity` captures multiple units of that same item, not multiple different items).
- "Member" = active membership at the time of a given order (`order_date` between `membership_start_date` and `membership_end_date` or ongoing if `membership_end_date` is NULL).

## Core Questions

1. [Orders & Revenue Overview](#1-orders--revenue-overview): How busy was the café — how many orders did we serve and how much revenue did we bring in? Return total orders and total revenue.

2. [Customer Loyalty Segments](#2-customer-loyalty-segments): Which customers keep coming back? Categorise customers with more than 6 orders as 'regulars', exactly 1 order as 'one-time', and everyone else as 'occasional'. Return customer ID, total orders, and visit frequency category, sorted by highest orders.

3. [Popularity vs. Profitability](#3-popularity-vs-profitability): What are customers actually drinking, and which of those drinks are the real money-makers? Return coffee name, total quantity sold, percentage of total volume (rounded to 2 decimal places), total revenue, and percentage of total revenue (rounded to 2 decimal places) — so it's clear whether the most popular item is also the most profitable one.

4. [Peak Revenue Days](#4-peak-revenue-days): Are there peak days — which days of the week bring in the most revenue? Return day of the week, number of times that day occurred, total revenue, and average revenue per occurrence (rounded to 2 decimal places), sorted by total revenue descending and limited to the top 5 days.

5. [Top Spending Customers](#5-top-spending-customers): Who are our best customers — which 10 customers spend the most overall? Return customer ID, total spent, percentage of total revenue (rounded to 2 decimal places), and spend rank, sorted by total spent descending and limited to the top 10.

6. [Membership Status Breakdown](#6-membership-status-breakdown): How many of our customers are currently members, lapsed, or never joined? Return membership status (active member, lapsed member, never joined) and customer count for each.

7. [Member vs. Non-Member Value](#7-member-vs-non-member-value): Are members actually valuable?

    For every order, work out whether that customer was a member or a non-member *at the time of that specific order* — not their current status. The same customer can land in both groups, depending on when each order happened relative to their membership dates.

    Return: status (member/non-member), number of customers, total orders, average orders per customer (rounded to 2 decimal places), total revenue, and average spend per order (rounded to 2 decimal places).

    > **How to read `membership_start_date` and `membership_end_date` together:**
    >
    > | membership_start_date | membership_end_date | status |
    > |------------------------|----------------------|----------------|
    > | NULL | NULL | never joined |
    > | has a date | NULL | active member |
    > | has a date | has a date | lapsed member |

## Advanced Questions

8. [Customer's Usual Order](#8-customers-usual-order): Does each customer have a "usual"? Return customer ID, drink name, number of times ordered, and rank — showing all ties (via `DENSE_RANK()`), not just a single top pick — sorted by customer ID, limited to the first 5 customers (note: ties mean some of those 5 customers may contribute more than one row each).

9. [Time to Convert](#9-time-to-convert): How long does it typically take a customer to convert into a member? Return customer ID, first order date, membership start date, days to convert, and the average days-to-convert across all members (rounded to 2 decimal places) — sorted by customer ID, limited to the first 5 customers (the average itself should still reflect all members, not just the 5 shown).

10. [Post-Lapse Drop-Off](#10-post-lapse-drop-off): When a customer's membership lapses, does their ordering drop off afterward? Return customer ID, total orders placed while an active member, orders per month while an active member (rounded to 2 decimal places), total orders placed after lapsing, and orders per month after lapsing (rounded to 2 decimal places), sorted by customer ID.

11. [RFM Customer Segmentation](#11-rfm-customer-segmentation): Which customers are most valuable when you weigh how recently, how often, and how much they spend — not spend alone? For each customer, calculate recency (days since their last order), frequency (total orders), and monetary value (total spend), then score each dimension into quartiles using `NTILE(4)`. Return customer ID, recency, frequency, monetary value, and the three quartile scores. *(Note: a higher score is better across all three dimensions — quartile 4 means most recent, most frequent, or highest spend; quartile 1 means the opposite. Recency needs to be scored in the opposite sort direction from frequency and monetary to achieve this, since a smaller day-count is what counts as "better" for recency.)*

12. [Month-over-Month Revenue Growth](#12-month-over-month-revenue-growth): Using 2025 order data only, how is revenue trending month to month — accelerating, slowing, or flat? Return month, total revenue, the previous month's revenue, and % change (rounded to 2 decimal places), ordered chronologically by month, using `LAG()`. *(Note: 2026 data is excluded — it's a single month containing all of the original "walk-in" orders and would show an artificial spike rather than a real trend.)*

## Case Study Solution

## Core Questions 

### 1. Orders & Revenue Overview

How busy was the café - how many orders did we serve and how much revenue did we bring in? Return total orders and total revenue.

```sql
SELECT
    COUNT(DISTINCT orders.order_id) AS total_orders,
    SUM(orders.quantity * menu.price) AS total_revenue
FROM orders
INNER JOIN menu
    ON orders.menu_id = menu.menu_id;
```

**✅ Result:**
| total_orders | total_revenue |
|---|---|
| 400 | 8661.40 |

**💡 Commentary:**
Ems Coffee served 400 orders for RM8,661.40 in revenue which is an average order value (AOV) of roughly RM21.65. On its own, it's a one-line figure and we have yet to know whether that revenue is concentrated in a handful of customers or spread evenly which is what the customer segmentation in Q2 and Q5 will unpack. 

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
| visit_frequency | num_of_customers | pct_of_customers | total_orders | pct_of_orders |
|---|---|---|---|---|
| regular | 30 | 75.00 | 365 | 91.25 |
| occasional | 7 | 17.50 | 32 | 8.00 |
| one-time | 3 | 7.50 | 3 | 0.75 |

**💡 Commentary:**
Regular customers make up 75% (30 out of 40 customers) of Ems Coffee's customers, but they're responsible for 91.25% of all orders. Occasional customers represent a modest 8% and one-time customers barely register at 0.75%. 

This confirms the earlier point with real numbers: almost the entire business runs on a small core of repeat customers, not a wide base of casual visitors.

### 3. Popularity vs. Profitability 

What are customers actually drinking, and which of those drinks are the real money-makers? 

Return coffee name, total quantity sold, percentage of total volume (rounded to 2 decimal places), total revenue, and percentage of total revenue (rounded to 2 decimal places) so it's clear whether the most popular item is also the most profitable one.

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

Are there peak days — which days of the week bring in the most revenue? 

Return day of the week, number of times that day occurred, total revenue, and average revenue per occurrence (rounded to 2 decimal places) sorted by total revenue descending and limited to the top 5 days.

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

Who are our best customers - which 10 customers spend the most overall? 

Return customer ID, total spent, percentage of total revenue (rounded to 2 decimal places), and spend rank sorted by total spent descending and limited to the top 10.

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

Are members *actually* valuable? For every order, work out whether that customer was a member or a non-member *at the time of that specific order* — not their current status. The same customer can land in both groups depending on when each order happened relative to their membership dates. 

Return status (member/non-member), number of customers, total orders, average orders per customer (rounded to 2 decimal places), total revenue, and average spend per order (rounded to 2 decimal places).

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

## Advanced Questions

### 8. Customer's Usual Order

Does each customer have a "usual"? 

Return customer ID, drink name, number of times ordered, and rank — showing all ties (via `DENSE_RANK()`), not just a single top pick sorted by customer ID, limited to the first 5 customers *(note: ties mean some of those 5 customers may contribute more than one row each)*.

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

How long does it typically take a customer to convert into a member? 

Return customer ID, first order date, membership start date, days to convert, and the average days-to-convert across all members (rounded to 2 decimal places) sorted by customer ID and limited to the first 5 customers (the average itself should still reflect all members, not just the 5 shown).

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
GROUP BY 
    customers.customer_id, 
    membership_start_date
ORDER BY customers.customer_id;
```

**✅ Result:**
(showing first 5 rows of results)
| customer_id | first_order_date | membership_start_date | days_to_convert | avg_days_to_convert |
|-------------|-------------------|-------------------------|------------------|-----------------------|
| 1           | 2025-01-01        | 2025-01-05              | 4                | 39.88                 |
| 3           | 2025-01-01        | 2025-02-10              | 40               | 39.88                 |
| 4           | 2025-01-15        | 2025-03-01              | 45               | 39.88                 |
| 5           | 2025-01-01        | 2025-01-20              | 19               | 39.88                 |
| 7           | 2025-01-01        | 2025-02-15              | 45               | 39.88                 |

**💡 Commentary:**
Conversion time varies a fair bit. Customer 1 joined just 4 days after their first order while customers 4 and 7 both took 45 days over 11 times longer. The overall average across all 24 members is 39.88 days which actually sits below what's typical: the single most common outcome is 45 days (12 of the 24 members) and a handful of much faster converters (4-40 days) are what pull the average down below that.

### 10. Post-Lapse Drop-Off

When a customer's membership lapses, does their ordering drop off afterward? 

Return customer ID, total orders placed while an active member, orders per month while an active member (rounded to 2 decimal places), total orders placed after lapsing, and orders per month after lapsing (rounded to 2 decimal places) sorted by customer ID.

**Step-by-Step Breakdown:**

This query might be a little complex (it took me some time to figure it out too!) so I'm sharing the step-by-step to get you in the right direction.
- Step 1: 
    - In the 1st query wrapped as `orders_data` CTE, find the number of active and lapsed orders using `COUNT(CASE WHEN ...)`.
    - Only keep data where the `membership_end_date` isn't null to exclude customers who never joined or are still active.
    - Group by customer ID plus the membership dates.

| `order_date` relative to membership window                        | Counted as                        |
|--------------------------------------------------------------------|-------------------------------------|
| before `membership_start_date`                                     | neither (excluded from both counts) |
| between `membership_start_date` and `membership_end_date` (inclusive) | active                          |
| after `membership_end_date`                                        | lapsed                             |

- Step 2: In the 2nd query wrapped as `snapshot_data` CTE, we retrieve the latest date of order in the entire data as a single value. More on this in the next step.
- Step 3:
    - First, convert the membership length from days into months: (membership_end_date − membership_start_date) ÷ 30.0.
    - Then, divide: number of active orders ÷ number of months as an active member.
    - Do the same for lapsed orders by using (snapshot date - membership_end_date) instead. 
    - Why? The absolute number of active and lapsed orders on its own doesn't tell much. But, dividing it with the number of months the customer has been member or lapsed member tells a more accurate story.

```sql
WITH orders_data AS (
    SELECT
        orders.customer_id,
        customers.membership_start_date,
        customers.membership_end_date,
        COUNT(
            CASE WHEN orders.order_date BETWEEN customers.membership_start_date AND customers.membership_end_date THEN 1 END
            ) AS active_orders,
        COUNT(
            CASE WHEN orders.order_date > customers.membership_end_date THEN 1 END
            ) AS lapsed_orders
    FROM orders
    INNER JOIN customers 
        ON orders.customer_id = customers.customer_id
    WHERE customers.membership_end_date IS NOT NULL
    GROUP BY 
        orders.customer_id,
        customers.membership_start_date,
        customers.membership_end_date
)
, snapshot_data AS (
    SELECT MAX(order_date) AS snapshot_date
    FROM orders
)

SELECT
	customer_id,
    active_orders,
    ROUND(
        active_orders/
        NULLIF((membership_end_date - membership_start_date) / 30.0, 0)
        ,2) AS active_orders_per_month,
    lapsed_orders,
    ROUND(
        lapsed_orders/
        NULLIF((snapshot_date - membership_end_date) / 30.0, 0)
        ,2) AS lapsed_orders_per_month
FROM orders_data
CROSS JOIN snapshot_data
ORDER BY customer_id;
```

**✅ Result:**
| customer_id | active_orders | active_orders_per_month | lapsed_orders | lapsed_orders_per_month |
|-------------|----------------|---------------------------|-----------------|----------------------------|
| 1           | 8              | 1.63                       | 2               | 0.20                        |
| 4           | 8              | 1.30                       | 3               | 0.43                        |
| 7           | 4              | 1.35                       | 3               | 0.28                        |
| 10          | 9              | 1.49                       | 4               | 0.49                        |
| 13          | 6              | 1.18                       | 3               | 0.40                        |
| 16          | 6              | 1.50                       | 2               | 0.21                        |
| 19          | 7              | 1.15                       | 2               | 0.36                        |
| 23          | 9              | 1.47                       | 1               | 0.16                        |
| 25          | 9              | 1.49                       | 2               | 0.23                        |
| 29          | 7              | 0.98                       | 3               | 0.70                        |

**💡 Commentary:**
Every single one of these 10 lapsed customers orders less often than they did while active which is a pretty clean result. But the size of the drop varies a lot: customer 29 barely slows down going from 0.98 to 0.70 orders/month (about a 29% drop) while customer 23 falls off significantly from 1.47 down to 0.16 (about 89% drop) - that's close to disappearing as a customer entirely! 😦

### 11. RFM Customer Segmentation

Which customers are most valuable when you weigh how recently, how often, and how much they spend — not spend alone? For each customer, calculate recency (days since their last order), frequency (total orders), and monetary value (total spend), then score each dimension into quartiles using NTILE(4). 

Return customer ID, recency, frequency, monetary value, and the three quartile scores.

*(Note: A higher score is better across all three dimensions — quartile 4 means most recent, most frequent, or highest spend; quartile 1 means the opposite. Recency needs to be scored in the opposite sort direction from frequency and monetary to achieve this since a smaller day-count is what counts as "better" for recency.)*

**What's RFM?**

Here's a quick rundown of what RFM Customer Segmentation is:
- **Recency 📅** is how long it's been since their last order (in days) as in "how active/engaged they are". 
- **Frequency ☕️** is just their total order count, basically "how often they show up". 
- **Monetary 💵** is total spend - "how much they've put into the cashier overall". 

The idea is that ranking customers by any single one of these on its own gives a distorted picture. A customer could spend a lot in total just because they were a customer for years, even if they've gone quiet recently, or someone could order constantly, but always in small amounts. RFM looks at all three at once instead of picking one and calling it "value."

Here's where `NTILE(4)` comes into the picture.

It turns recency, frequency, and monetary numbers into a comparable score, splitting the customers into 4 equal-sized buckets based on where they rank on that metric (quartile 1 through quartile 4) so instead of comparing "RM384.30" to "RM12.50", you're comparing "top 25% spender" to "bottom 25% spender." 

To put it into query perspective:
- **Recency** = Days between each customer's last order and the most recent order date *in the dataset*
- **Frequency** = Total number of orders
- **Monetary** = Total amount spend across all orders

```sql
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
```

**✅ Result:**
(showing first 10 rows)
| customer_id | recency | frequency | monetary | recency_score | frequency_score | monetary_score |
|-------------|---------|-----------|----------|----------------|-------------------|------------------|
| 1           | 128     | 11        | 308.40   | 2              | 2                  | 4                |
| 2           | 117     | 10        | 143.10   | 2              | 2                  | 2                |
| 3           | 64      | 14        | 284.40   | 3              | 4                  | 3                |
| 4           | 143     | 13        | 300.00   | 1              | 4                  | 3                |
| 5           | 104     | 9         | 198.70   | 2              | 2                  | 2                |
| 6           | 0       | 14        | 202.80   | 4              | 4                  | 2                |
| 7           | 153     | 10        | 248.20   | 1              | 2                  | 3                |
| 8           | 73      | 13        | 315.30   | 3              | 4                  | 4                |
| 9           | 7       | 12        | 212.10   | 4              | 3                  | 2                |
| 10          | 97      | 15        | 348.30   | 3              | 4                  | 4                |

Let's go one step further and keep only customers who scored 4-4-4 on all customer metrics.

```sql
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
```

**✅ Result:**
| customer_id | recency | frequency | monetary | recency_score | frequency_score | monetary_score |
|-------------|---------|-----------|----------|-----------------|--------------------|----------------------|
| 15          | 39      | 13        | 310.30   | 4               | 4                  | 4                    |
| 29          | 55      | 14        | 327.40   | 4               | 4                  | 4                    |

**💡 Commentary:**
2 customers score a clean 4-4-4 across the board (customers 15 and 29) - recently active, ordering frequently, and among the higher spenders. These are your model customers.

At the other end, 6 customers score 1-1-1. All 10 of the lowest-scoring customers (31-40) turn out to be people who never joined the membership program at all, mostly 1 to 5 lifetime orders and spent under RM80 total. This lines up with the "one-time"/"occasional" segments from Q2.

The more interesting group sits in between: 4 customers (4, 7, 13, 23) score a 1 on recency despite scoring 3 or 4 on frequency or monetary, meaning they used to be high-spending customers, but haven't ordered in a while. Customer 23 stands out here specifically with a RM384.30 total spend, the highest in the dataset, but hasn't ordered in 153 days. That's a concrete win-back target: not a customer to write off, but one worth a nudge before they're gone for good.

### 12. Month-over-Month Revenue Growth

Using 2025 order data only, how is revenue trending month to month — accelerating, slowing, or flat? 

Return month, total revenue, the previous month's revenue, and % change (rounded to 2 decimal places), ordered chronologically by month, using LAG(). 

*(Note: 2026 data is excluded. It's a single month containing all of the original "walk-in" orders and would show an artificial spike rather than a real trend.)*

```sql
WITH revenue_data AS (
    SELECT
        TO_CHAR(order_date, 'YYYY-MM') AS mth_yr,
        SUM(quantity * price) AS total_revenue
    FROM orders
    INNER JOIN menu
        ON orders.menu_id = menu.menu_id
    WHERE order_date < '2026-01-01'
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
, lag_data AS (
    SELECT
        mth_yr,
        total_revenue,
        LAG(total_revenue) OVER (ORDER BY mth_yr) AS prev_mth_revenue
    FROM revenue_data
)

SELECT
	mth_yr,
    total_revenue AS current_mth_revenue,
    LAG(total_revenue) OVER (ORDER BY mth_yr) AS prev_mth_revenue,
    ROUND(100.0 * (total_revenue - prev_mth_revenue)/prev_mth_revenue,2) AS pct_change 
FROM lag_data
ORDER BY mth_yr;
```

**✅ Result:**
| mth_yr  | total_revenue | prev_mth_revenue | pct_change |
|---------|---------------|------------------|------------|
| 2025-01 |        874.10 |                  |            |
| 2025-02 |        678.90 |           874.10 |     -22.33 |
| 2025-03 |        783.20 |           678.90 |      15.36 |
| 2025-04 |        896.60 |           783.20 |      14.48 |
| 2025-05 |        918.40 |           896.60 |       2.43 |
| 2025-06 |        638.50 |           918.40 |     -30.48 |
| 2025-07 |        815.30 |           638.50 |      27.69 |
| 2025-08 |        634.60 |           815.30 |     -22.16 |
| 2025-09 |        467.50 |           634.60 |     -26.33 |
| 2025-10 |        477.60 |           467.50 |       2.16 |
| 2025-11 |        556.00 |           477.60 |      16.42 |
| 2025-12 |        362.40 |           556.00 |     -34.82 |

**💡 Commentary:**
Revenue varies a lot from month to month so there isn't a steady acceleration or slowdown. 

If there's a pattern at all, it's that the second half of the year runs slower than the first; roughly RM4,790 total for Jan-Jun vs. RM3,313 for Jul-Dec with December being the weakest month at RM362.40. 

***
