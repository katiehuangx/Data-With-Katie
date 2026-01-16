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

### 3. For each date, calculate the 7-day rolling average revenue.

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:


</details>


***

## 👥 Customer Insights & Segmentation
KPIs: Customer Lifetime Value (CLV), Retention Rate, Spend Buckets, Multi-Channel Usage


### 1. Who are the top 5 customers by total spend (Customer Lifetime Value)?

<details> 
<summary> ▶️ Show solution</summary>

```sql

```

✅ Expected result:
| **count** |
|-----------|
| 297       |

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

