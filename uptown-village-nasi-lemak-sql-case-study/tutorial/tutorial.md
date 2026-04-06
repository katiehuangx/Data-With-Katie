# 📚 SQL Tutorial

The tutorial questions are arranged in increasing difficulty. Each question comes with steps and a short explanation of the concept it teaches, so you can practice and build your confidence step by step. 😉

📝 Note from Katie:
- To check your answers, click on the **▶️ Show solution** toggle under each question to view the solution. 
- There are multiple ways to solve the questions, so feel free to present your answers differently! You can add extra columns for percentages, totals, rankings. This isn't an exam or an interview. 🙂
- I HIGHLY encourage you to practice on your own using the DB Fiddle - SQL Data Playground. Better yet, add this into your portfolio project! You can use the questions_only.md file and insert your own solutions. If you get stuck on this, drop me a message on Linkedin.

## 1. How many total orders has the restaurant received?

In SQL talk: Count the number of rows in the `orders` table. 

- **Step 1:** Identify table where the data is from → `uptown_nasi_lemak.orders`. 
- **Step 2:** Use `COUNT(*)` or `COUNT(order_id)` to count the rows. 
- **Step 3:** Give the result a meaningful column name `AS total_orders`.

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT COUNT(*) AS total_orders
FROM uptown_nasi_lemak.orders;
```

✅ Expected result:
| **total_orders** |
 |------------------------|
| 300                    |

</details>

## 2. How many unique customers are have placed at least one order?

In SQL talk: Use the `orders` table to calculate the total number of distinct customers.

- **Step 1:** Identify table with customer IDs → `uptown_nasi_lemak.orders`.
- **Step 2:** Use `COUNT(DISTINCT customer_id)` to count unique values.

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM uptown_nasi_lemak.orders;
```

✅ Expected result:
| **unique_customers** |
|----------------------------|
| 50                         |

</details>

## 3. What does our menu pricing look like, starting from the most expensive dishes.

In SQL talk: Use the menu table to list all dishes and their prices sorted from highest to lowest price.

- **Step 1:** Identify table where data is stored → `uptown_nasi_lemak.menu`.
- **Step 2:** Select columns you want to display → `food_name` and `price`.
- **Step 3:** Sort results so that the most expensive dishes appear first → `ORDER BY column DESC`

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT 
  food_name, 
  price
FROM uptown_nasi_lemak.menu
ORDER BY price DESC;
```

✅ Expected result: 
| **food_name**                                                      | **price** |
|--------------------------------------------------------------------|----------------|
| Nasi Lemak Sotong (Squid Sambal Nasi Lemak)                        | 14.50          |
| Nasi Lemak Ayam Goreng (Fried Chicken Nasi Lemak)                  | 12.00          |
| Nasi Lemak Telur Mata (Egg Nasi Lemak)                             | 7.50           |
| Sambal Sotong Extra (Spicy Squid Sambal)                           | 6.50           |
| Fried Chicken Wing                                                 | 5.00           |
| Milo Ais (Iced Chocolate Malt Drink)                               | 4.50           |
| Sirap Bandung (Rose Syrup with Milk)                               | 4.00           |
| Teh Tarik (Pulled Milk Tea)                                        | 3.50           |
| Roti Bakar Butter & Kaya (Toasted Bread with Butter & Coconut Jam) | 3.20           |
| Telur Separuh Masak (Half-Boiled Eggs)                             | 2.50           |


</details>

### 4. How much total revenue has the restaurant generated from all customer orders?

In SQL talk: Calculate total revenue by summing the value of all completed orders.

📌 **Why is this important to businesses?:** Revenue tracking is the foundation of every financial report and is typically the first metric reviewed in the monthly Profit & Loss.

- **Step 1:** Use `uptown_nasi_lemak.orders` table to retrieve the order quantity and price of food.
- **Step 2:** Mutiply `quantity` and `price` then apply `SUM` to add up revenue from all rows.

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT SUM(quantity*price) AS total_revenue
FROM uptown_nasi_lemak.orders
```

✅ Expected result:
| **total_revenue** |
|-------------------|
| 3894.30           |

</details>


## 5. Which dishes are the most popular based on number of orders? Sort results in descending order.

In SQL talk: Count how many times each dish was ordered and rank them from most to least ordered.

- **Step 1:** Join `uptown_nasi_lemak.orders` and `uptown_nasi_lemak.menu` to match orders with dish names.  
- **Step 2:** Use `COUNT(order_id)` grouped by `food_name` to find the number of times each dish was ordered.  
- **Step 3:** Sort results in ascending order by the count.  

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT 
	menu.food_name,
  COUNT(orders.order_id) AS order_count
FROM uptown_nasi_lemak.orders AS orders
INNER JOIN uptown_nasi_lemak.menu AS menu
	ON orders.food_id = menu.food_id
GROUP BY menu.food_name
ORDER BY order_count DESC;
```

📌 It might feel easier to group by `food_id` and return the IDs, but in real-world reporting, IDs alone usually aren’t meaningful to business users. 

Showing the **actual dish names** makes your output more presentation-ready, easier to understand and more useful when sharing insights with the restaurant owners.

✅ Expected result:
| **food_name**                                     | **order_count** |
|---------------------------------------------------|------------------------|
| Nasi Lemak Ayam Goreng (Fried Chicken Nasi Lemak) | 53                     |
| Nasi Lemak Sotong (Squid Sambal Nasi Lemak)       | 53                     |
| Nasi Lemak Telur Mata (Egg Nasi Lemak)            | 51                     |
| Sambal Sotong Extra (Spicy Squid Sambal)          | 48                     |
| Teh Tarik (Pulled Milk Tea)                       | 48                     |
| Fried Chicken Wing                                | 47                     |

</details>

## 6. Which order channels bring in the most orders? Sort results by highest number of orders.

In SQL talk: Group orders by channel and rank channels by total order volume.

- **Step 1:** Join `uptown_nasi_lemak.orders` with `uptown_nasi_lemak.order_channels` using `channel_id`.
- **Step 2:** Count how many `order_id` values appear for each channel.
- **Step 3:** Group by `channel_name` and sort results in descending order.

📌 Splitting by channel helps businesses evaluate the return on investment (ROI) of delivery partnerships and optimize staff allocation across delivery vs. dine-in vs. takeaway.

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT 
  channels.channel_name,
	COUNT(orders.order_id) AS no_of_orders
FROM uptown_nasi_lemak.orders AS orders
INNER JOIN uptown_nasi_lemak.order_channels AS channels
	ON orders.channel_id = channels.channel_id
GROUP BY channels.channel_name
ORDER BY no_of_orders DESC;
```

✅ Expected result:  
| **channel_name** | **no_of_orders** |
|------------------|------------------|
| Dine-In          | 108              |
| Takeaway         | 100              |
| GrabFood         | 92               |

</details>

## 7. Which menu item generated the most revenue?

In SQL talk: Calculate revenue by dish and identify the top-performing menu item.

📈 **Corporate Insight:** Knowing the top-earning dish helps restaurants decide what to feature on menus, run promotions for or ensure that supply is never short.

- **Step 1:** Join `uptown_nasi_lemak.orders` with `uptown_nasi_lemak.menu`.
- **Step 2:** Group by `food_name` and calculate the revenue. 
- **Step 3:** Order revenue in descending order (highest) and pick the top result.

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT 
	menu.food_name,
  SUM(orders.quantity*orders.price) AS highest_revenue_generated
FROM uptown_nasi_lemak.orders AS orders
INNER JOIN uptown_nasi_lemak.menu AS menu
	ON orders.food_id = menu.food_id
GROUP BY menu.food_name
ORDER BY highest_revenue_generated DESC
LIMIT 1;
```

✅ Expected result: 
| food_name         | highest_revenue_generated |
| ----------------- | ---------------------- |
| Sambal Sotong Extra (Spicy Squid Sambal) | 864.00                  |

</details>

## 8. Which order channels drive the highest average spend per order? Round results to 2 decimal points.

In SQL talk: Calculate the average order value (revenue) for each sales channel.

- **Step 1:** Join `orders` and `order_channels` tables. 
- **Step 2:** Calculate the revenue, average it out and round to 2 decimals.
- **Step 3:** Order results from highest to lowest to see which channel has the highest AOV.

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT 
  channels.channel_name,
  ROUND(AVG(orders.quantity*price),2) AS avg_order_value
FROM uptown_nasi_lemak.orders AS orders
INNER JOIN uptown_nasi_lemak.order_channels AS channels
  ON orders.channel_id = channels.channel_id
GROUP BY channels.channel_name
ORDER BY avg_order_value DESC;
```

✅ Expected result:
| **channel_name** | **avg_order_value** |
|------------------|---------------------|
| Takeaway         | 15.48               |
| GrabFood         | 12.84               |
| Dine-In          | 10.79               |

</details>

📈 **Corporate Insight:** Average order value (AOV) is a key business metric. It identifies which sales channels (e.g., dine-in, takeaway, delivery) bring in customers who spend more per order. This helps businesses decide where to focus their efforts and which channels are worth optimizing further. 

## 9. How is the restaurant’s revenue trending month by month? Calculate the total revenue by month.

In SQL talk: Calculate total revenue by month to track sales trends over time. You can use any datetime function for the month as long it makes sense to business users. 

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT
  TO_CHAR(order_date, 'YYYY-MM') AS mth,
  SUM(quantity*price) AS total_revenue
FROM uptown_nasi_lemak.orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY mth;
```

✅ Expected result: 
| **mth** | **total_revenue** |
|---------|-------------------|
| 2025-01 | 2670.50           |
| 2025-02 | 355.20            |
| 2025-03 | 395.40            |
| 2025-04 | 371.00            |
| 2025-05 | 102.20            |

</details>

## 10. How do our dishes rank in popularity and how do different ranking methods affect the results?

In SQL talk: Rank dishes based on total order count using RANK(), DENSE_RANK(), and ROW_NUMBER(). Include a tie-breaker  

<details> 
<summary> ▶️ Show solution</summary>

```sql
WITH dishes_popularity AS (
  SELECT 
    menu.food_name,
    COUNT(orders.order_id) AS order_count
  FROM uptown_nasi_lemak.orders AS orders
  INNER JOIN uptown_nasi_lemak.menu AS menu
  	ON orders.food_id = menu.food_id
  GROUP BY menu.food_name
)

SELECT 
	food_name,
  order_count,
  RANK() OVER (ORDER BY order_count DESC) AS rank_seq,
	DENSE_RANK() OVER (ORDER BY order_count DESC) AS dense_rank_seq,
  ROW_NUMBER() OVER (ORDER BY order_count DESC, food_name ASC) AS row_number_seq
FROM dishes_popularity
ORDER BY food_name;
```

✅ Expected result:

Hi it's Katie here, I want you to stay with me and go through the results together. It's crucial that you understand the difference of the ranking functions. 

Ok, so the 1st column, order_count is the total orders. Use that as a reference column. 
- Let's go through row 1 and 2. Both dishes have 53 orders. RANK and DENSE_RANK returned them as 1 and 1 because it considers them as equal. ROW_NUMBER returned as 1 and 2 because the function needs to assign a unique, sequential integer. 



| **food_name**                                     | **order_count** | **rank_seq** | **dense_rank_seq** | **row_number_seq** |
|---------------------------------------------------|-----------------|--------------|--------------------|--------------------|
| Nasi Lemak Sotong (Squid Sambal Nasi Lemak)       | 53              | 1            | 1                  | 1                  |
| Nasi Lemak Ayam Goreng (Fried Chicken Nasi Lemak) | 53              | 1            | 1                  | 2                  |
| Nasi Lemak Telur Mata (Egg Nasi Lemak)            | 51              | 3            | 2                  | 3                  |
| Teh Tarik (Pulled Milk Tea)                       | 48              | 4            | 3                  | 4                  |
| Sambal Sotong Extra (Spicy Squid Sambal)          | 48              | 4            | 3                  | 5                  |
| Fried Chicken Wing                                | 47              | 6            | 4                  | 6                  |

</details>

## 11. Within each channel, rank customers by total spend using DENSE_RANK() and return the top 2.  

<details> 
<summary> ▶️ Show solution</summary>

```sql
WITH customer_total_spending AS (
  SELECT
    channels.channel_name,
    orders.customer_id,
    SUM(orders.quantity*orders.price) AS total_spend
  FROM uptown_nasi_lemak.orders AS orders
  INNER JOIN uptown_nasi_lemak.order_channels AS channels
    ON orders.channel_id = channels.channel_id
  GROUP BY channels.channel_name, orders.customer_id
)
, ranked_spending AS (
  SELECT 
    channel_name,
    customer_id,
    total_spend,
    DENSE_RANK() OVER (
      PARTITION BY channel_name 
      ORDER BY total_spend DESC) AS dense_rank_seq
  FROM customer_total_spending
)

SELECT 
	channel_name,
  customer_id,
  total_spend,
  dense_rank_seq
FROM ranked_spending
WHERE dense_rank_seq < 3;
```

✅ Expected result:
| **channel_name** | **customer_id** | **total_spend** | **dense_rank_seq** |
|--------------|-------------|-------------|----------------|
| Dine-In      | C001        | 105.60      | 1              |
| Dine-In      | C007        | 72.60       | 2              |
| GrabFood     | C005        | 59.20       | 1              |
| GrabFood     | C046        | 46.80       | 2              |
| GrabFood     | C008        | 46.80       | 2              |
| GrabFood     | C040        | 46.80       | 2              |
| GrabFood     | C034        | 46.80       | 2              |
| GrabFood     | C002        | 46.80       | 2              |
| Takeaway     | C007        | 63.70       | 1              |
| Takeaway     | C008        | 62.30       | 2              |

</details>

## 12. Calculate the monthly revenue and show the running total and month-over-month percentage change.

<details> 
<summary> ▶️ Show solution</summary>

```sql
WITH revenue_by_mth AS (
  SELECT
    TO_CHAR(order_date, 'YYYY-MM') AS order_mth,
    SUM(quantity*price) AS total_revenue
  FROM uptown_nasi_lemak.orders
  GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)

SELECT
	order_mth,
  total_revenue,
  SUM(total_revenue) OVER (ORDER BY order_mth) AS running_total,
  ROUND(
    100.0*(total_revenue - LAG(total_revenue) OVER (ORDER BY order_mth))
    /LAG(total_revenue) OVER (ORDER BY order_mth),1) AS pct_change
FROM revenue_by_mth;
```

✅ Expected result:
| **order_mth** | **total_revenue** | **running_total** | **pct_change** |
|---------------|-------------------|-------------------|----------------|
| 2025-01       | 2670.50           | 2670.50           | null           |
| 2025-02       | 355.20            | 3025.70           | -86.7          |
| 2025-03       | 395.40            | 3421.10           | 11.3           |
| 2025-04       | 371.00            | 3792.10           | -6.2           |
| 2025-05       | 102.20            | 3894.30           | -72.5          |

</details>

***

Good job! You've completed the tutorial. Give yourself a pat on the back. 🎉

Now it’s time to put your skills to the test with the Assignment!
