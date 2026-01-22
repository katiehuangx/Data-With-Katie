# 📝 Assignment 

## 📈 Revenue & Sales Performance
KPIs: Total Revenue, Revenue by Channel, Growth Rate, Best-Selling Product, Rolling Revenue

### 1. What percentage of total revenue came from each order channel (Dine-In, Takeaway, GrabFood). Sort by the largest percentage.

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT
	channels.channel_name,
    ROUND(100.0*
		(SUM(orders.price*orders.quantity))
        /(SELECT SUM(price*quantity) FROM orders),2) AS revenue_perc
FROM uptown_nasi_lemak.orders AS orders
INNER JOIN uptown_nasi_lemak.order_channels AS channels
	ON orders.channel_id = channels.channel_id
GROUP BY channels.channel_name
ORDER BY revenue_perc DESC;
```

✅ Expected result:
| **channel_name** |  **revenue_perc** |
|------------------|-------------------|
| Takeaway         |  39.75            |
| GrabFood         |  30.34            |
| Dine-In          |  29.91            |

</details>

### 2. For each channel, identify the best-selling dish based on total revenue.

<details> 
<summary> ▶️ Show solution</summary>

```sql
WITH food_revenue AS (
    SELECT
        channels.channel_name,
        menu.food_name, 
        SUM(orders.price*orders.quantity) AS total_revenue
    FROM uptown_nasi_lemak.orders AS orders
    INNER JOIN uptown_nasi_lemak.order_channels AS channels
        ON orders.channel_id = channels.channel_id
    INNER JOIN uptown_nasi_lemak.menu AS menu
        ON orders.food_id = menu.food_id
    GROUP BY channels.channel_name, menu.food_name
),
ranked_dishes AS (
    SELECT
        channel_name,
        food_name,
        total_revenue,
        ROW_NUMBER () OVER 
            (PARTITION BY channel_name
            ORDER BY total_revenue DESC) AS row_no
    FROM food_revenue
)

SELECT 
	channel_name,
	food_name,
	total_revenue
FROM ranked_dishes
WHERE row_no = 1;
```

✅ Expected result:
| **channel_name** | **revenue** | **revenue_perc** |
|------------------|-------------|------------------|
| Takeaway         | 1547.90     | 39.75            |
| GrabFood         | 1181.60     | 30.34            |
| Dine-In          | 1164.80     | 29.91            |

</details>

### 3. For each date, calculate the 7-day rolling average revenue in January.

Info: There are no missing days in January. 

<details> 
<summary> ▶️ Show solution</summary>

```sql
WITH daily_revenue_cte AS (
    SELECT 
        order_date,
        SUM(quantity*price) AS daily_revenue
    FROM uptown_nasi_lemak.orders
    WHERE EXTRACT(MONTH FROM order_date) = 1
    GROUP BY order_date
)

SELECT 
	order_date,
	daily_revenue,
    ROUND(AVG(daily_revenue) OVER (
      ORDER BY order_date
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS avg_7d_rolling_revenue
FROM daily_revenue_cte
```

✅ Expected result:
| order_date | daily_revenue | avg_7d_rolling_revenue |
| ---------- | ------------- | ---------------------- |
| 2025-01-01 | 86.50         | 86.50                  |
| 2025-01-02 | 115.60        | 101.05                 |
| 2025-01-03 | 150.70        | 117.60                 |
| 2025-01-04 | 115.70        | 117.13                 |
| 2025-01-05 | 131.50        | 120.00                 |
| 2025-01-06 | 164.00        | 127.33                 |
| 2025-01-07 | 99.40         | 123.34                 |
| 2025-01-08 | 128.60        | 129.36                 |

For each day in January:
- Take the current day - 7 January
- Look back up to 6 previous days and c ompute the average revenue across those days - 1 to 6 January
- The first complete window happens on January 7.

</details>


***

## 👥 Customer Insights & Segmentation
KPIs: Customer Lifetime Value (CLV), Retention Rate, Spend Buckets, Multi-Channel Usage


### 1. Who are the top 5 customers by total spend (Customer Lifetime Value)?

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT 
	customer_id,
    SUM(quantity*price) AS total_spend
FROM uptown_nasi_lemak.orders
GROUP BY customer_id
ORDER BY total_spend DESC
LIMIT 5;
```

✅ Expected result:
| customer_id | total_spend |
| ----------- | ----------- |
| C007        | 176.20      |
| C008        | 168.90      |
| C001        | 162.70      |
| C009        | 132.60      |
| C002        | 125.90      |

</details>

### 2. Which customers have placed orders using all 3 channels?

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:
| **count** |
|-----------|
| 297       |

</details>

### 3. What is the customer retention rate (customers with more than one order)?



<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:
| **count** |
|-----------|
| 297       |

</details>

***

## 🍲 Menu & Product Analysis
KPIs: Best-Selling Item, Order Volume by Product, Product Performance by Channel, Data Quality KPI

### 1. For each channel, find the top 2 dishes by revenue.

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:
| **count** |
|-----------|
| 297       |

</details>

