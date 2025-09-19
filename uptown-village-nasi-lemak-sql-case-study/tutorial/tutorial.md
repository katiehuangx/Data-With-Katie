# 📝 SQL Tutorial 

This tutorial is an introduction to SQL using a fun dataset inspired by a local Malaysian favourite: *Village Park Nasi Lemak 🍚🌶️🐔*. 

*(I'm Malaysian 🇲🇾 and I love Village Park's nasi lemak with crispy fried chicken 🍗 or what we call "ayam goreng" in Malay.)*

The tutorial questions are arranged in increasing difficulty ⬆️. We'll start with basics (**counting rows, selecting unique values and summing totals**) and gradually move into more advanced concepts (**joins, HAVING and CTEs**). 

Each question comes with a short explanation of the concept it teaches, so you can practice and build confidence step by step. 😉

If you’d like to:
- Check your answers → click the **▶️ Show solution 💡** toggle in each question to expand the solution. 
- Practice on your own or add into your portfolio → use the questions_only.md and insert your own solutions.

---

## Mini Sandbox (Warm-up for Absolute Beginners)


## 🌱 Absolute Beginner Section: “SQL Sandbox”

Visual guide to understand table relationships:
<p align="left">
  <img src="https://github.com/katiehuangx/Data-With-Katie/blob/main/uptown-village-nasi-lemak-sql-case-study/assets/erd.png" alt="Uptown Nasi Lemak ERD" width="700"/>
</p>

Link to Entity Relationship (ER) diagram: [here](https://github.com/katiehuangx/Data-With-Katie/blob/main/uptown-nasi-lemak-sql-case-study/assets/erd.png)

### 1. Show the first 10 rows of the orders table.

<details> 
<summary> ▶️ Show solution (Click to expand) </summary>

```sql
SELECT *
FROM uptown_nasi_lemak.orders
LIMIT 15;
```

✅ Expected result: 
| **order_id** | **customer_id** | **order_date** | **menu_id** | **channel_id** | **quantity** | **unit_price** |
|---|---|---|---|---|---|---|
| 1 | C001 | 2025-01-01 | F02 | 1 | 1 | 15.80 |
| 2 | C002 | 2025-01-01 | F01 | 1 | 1 | 12.20 |
| 3 | C003 | 2025-01-01 | F03 | 2 | 1 | 8.90 |
| 4 | C004 | 2025-01-02 | F01 | 2 | 1 | 12.20 |
| 5 | C005 | 2025-01-02 | F04 | 3 | 2 | 3.80 |
| 6 | C006 | 2025-01-02 | F02 | 1 | 1 | 15.80 |
| 7 | C007 | 2025-01-03 | F05 | 1 | 1 | 18.00 |
| 8 | C008 | 2025-01-03 | F06 | 2 | 2 | 15.50 |
| 9 | C009 | 2025-01-03 | F01 | 3 | 1 | 12.20 |
| 10 | C010 | 2025-01-03 | F03 | 1 | 1 | 8.90 |

</details>

### 2. Show the first 5 rows of the menu table.

<details> 
<summary> ▶️ Show solution (Click to expand) </summary>

```sql
SELECT *
FROM uptown_nasi_lemak.menu
LIMIT 5;
```

✅ Expected result: 
| **food_id** | **food_name** | **unit_price** | **category** |
|---|---|---|---|
| F01 | Nasi Lemak Ayam Goreng (Fried Chicken Nasi Lemak) | 12.00 | Main |
| F02 | Nasi Lemak Sotong (Squid Sambal Nasi Lemak) | 14.50 | Main |
| F03 | Nasi Lemak Telur Mata (Egg Nasi Lemak) | 7.50 | Main |
| F04 | Teh Tarik (Pulled Milk Tea) | 3.50 | Beverage |
| F05 | Sambal Sotong Extra (Spicy Squid Sambal) | 6.50 | Side |

</details>

### 3. List all unique channel name values.

<details> 
<summary> ▶️ Show solution (Click to expand) </summary>

```sql
SELECT DISTINCT channel_name
FROM uptown_nasi_lemak.order_channels;
```

✅ Expected result: 
| **channel_name** |
|------------------|
| GrabFood         |
| Takeaway         |
| Dine-In          |

</details>

### 4. What is the highest price in the menu? 

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT MAX(unit_price)
FROM uptown_nasi_lemak.orders;
```

✅ Expected result: 
| **max** |
|---------|
| 18.00   |

</details>

### 5. What is the lowest price in the menu? (Beginner)

<details> 
<summary> ▶️ Show solution (Click to expand) </summary>

```sql
SELECT MIN(unit_price)
FROM uptown_nasi_lemak.orders;
```

✅ Expected result: 
| **min** |
|---------|
| 3.80    |


</details>

### 6. How many rows are in the menu table? (Beginner)

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT COUNT(*)
FROM uptown_nasi_lemak.menu;
```

✅ Expected result: 
| **count** |
|-----------|
| 10        |

</details>

### 7. Show all orders where the channel_id = 1 (Dine-In). (Beginner)

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT *
FROM uptown_nasi_lemak.orders
WHERE channel_id = 1;
```

✅ Expected result: 
Result has 108 rows, so we're only showing you the first 5 rows of orders. 
| **order_id** | **customer_id** | **order_date** | **menu_id** | **channel_id** | **quantity** | **unit_price** |
|--------------|-----------------|----------------|-------------|----------------|--------------|----------------|
| 1            | C001            | 2025-01-01     | F02         | 1              | 1            | 15.80          |
| 2            | C002            | 2025-01-01     | F01         | 1              | 1            | 12.20          |
| 6            | C006            | 2025-01-02     | F02         | 1              | 1            | 15.80          |
| 7            | C007            | 2025-01-03     | F05         | 1              | 1            | 18.00          |
| 10           | C010            | 2025-01-03     | F03         | 1              | 1            | 8.90           |
</details>

### 8. List all distinct customer_ids. (Beginner)

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT DISTINCT customer_id
FROM uptown_nasi_lemak.customers;
```

✅ Expected result: 
Result has 50 rows, so we're only showing you the first 5 rows of customers. 
| **customer_id** |
|-----------------|
| C030            |
| C045            |
| C017            |
| C001            |
| C044            |

</details>

### 9. What are the names of all menu items available?

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT food_name
FROM uptown_nasi_lemak.menu;
```

✅ Expected result: 
| **food_name**                                                      |
|--------------------------------------------------------------------|
| Nasi Lemak Ayam Goreng (Fried Chicken Nasi Lemak)                  |
| Nasi Lemak Sotong (Squid Sambal Nasi Lemak)                        |
| Nasi Lemak Telur Mata (Egg Nasi Lemak)                             |
| Teh Tarik (Pulled Milk Tea)                                        |
| Sambal Sotong Extra (Spicy Squid Sambal)                           |
| Fried Chicken Wing                                                 |
| Roti Bakar Butter & Kaya (Toasted Bread with Butter & Coconut Jam) |
| Telur Separuh Masak (Half-Boiled Eggs)                             |
| Milo Ais (Iced Chocolate Malt Drink)                               |
| Sirap Bandung (Rose Syrup with Milk)                               |

</details>

### 10. Show the date of the earliest and latest orders. (Beginner/Intermediate)

<details> 
<summary> ▶️ Show solution (Click to expand) </summary>

```sql
SELECT 
	MIN(order_date),
    MAX(order_date)
FROM uptown_nasi_lemak.orders;
```

✅ Expected result: 
The earliest order is on January 1st, 2025 and latest order on May 7th, 2025.
| **min**    | **max**    |
|------------|------------|
| 2025-01-01 | 2025-05-07 |

</details>


---

## 🌱 SQL Tutorial (Level 1–3)

### 1. How many total orders were made?

We’re simply counting all the rows in the `orders` table since each row represents one order. 

💡 **Key Takeaway:** Overall sales volume is one of the first metrics leadership looks at to measure store performance at a glance.

- **Step 1:** Identify the table where the data is from → `uptown_nasi_lemak.orders`. 
- **Step 2:** Use `COUNT(*)` or `COUNT(order_id)` to count the rows. 
- **Step 3:** Give the result a meaningful column name `AS total_orders_count`.

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT COUNT(*) AS total_orders_count
FROM uptown_nasi_lemak.orders;
```

✅ Expected result:
| **total_orders_count** |
|------------------------|
| 300                    |

</details>

### 2. Retrieve the food_name and price for each menu item. (Beginner)

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT 
  food_name, 
  unit_price
FROM uptown_nasi_lemak.menu;
```

✅ Expected result: 
| **food_name**                                                      | **unit_price** |
|--------------------------------------------------------------------|----------------|
| Nasi Lemak Ayam Goreng (Fried Chicken Nasi Lemak)                  | 12.00          |
| Nasi Lemak Sotong (Squid Sambal Nasi Lemak)                        | 14.50          |
| Nasi Lemak Telur Mata (Egg Nasi Lemak)                             | 7.50           |
| Teh Tarik (Pulled Milk Tea)                                        | 3.50           |
| Sambal Sotong Extra (Spicy Squid Sambal)                           | 6.50           |
| Fried Chicken Wing                                                 | 5.00           |
| Roti Bakar Butter & Kaya (Toasted Bread with Butter & Coconut Jam) | 3.20           |
| Telur Separuh Masak (Half-Boiled Eggs)                             | 2.50           |
| Milo Ais (Iced Chocolate Malt Drink)                               | 4.50           |
| Sirap Bandung (Rose Syrup with Milk)                               | 4.00           |

</details>


### 3. What is the total number of unique customers?

We’re finding how many different customers placed an order. That means counting distinct `customer_id`s rather than rows.

- **Step 1:** Identify table with customer IDs → `uptown_nasi_lemak.orders`.
- **Step 2:** Use `COUNT(DISTINCT customer_id)` to count unique values.

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT COUNT(DISTINCT customer_id) AS unique_customers_count
FROM uptown_nasi_lemak.orders;
```

✅ Expected result:
| **unique_customers_count** |
|----------------------------|
| 50                         |

</details>

---

## 🛑 Intermediate (Level 4–6)

### 4. How many times was each dish ordered? Sort results in ascending order by the count. 
We want to see the popularity of each menu item. 

📌 **Business Note:** It might feel easier to group by `food_id` and output IDs, but in real-world reporting, IDs aren’t meaningful to business users. Showing the **actual dish names** makes the output presentation-ready, clearer, and more useful when sharing results with management.

- **Step 1:** Join the `uptown_nasi_lemak.orders` and `uptown_nasi_lemak.menu` to match orders with dish names.  
- **Step 2:** Use `COUNT(order_id)` grouped by `food_name` to find the number of times each dish was ordered.  
- **Step 3:** Sort the results in ascending order by the count.  

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT 
	menu.food_name,
  COUNT(orders.order_id) AS no_of_dish_ordered
FROM uptown_nasi_lemak.orders AS orders
INNER JOIN uptown_nasi_lemak.menu AS menu
	ON orders.food_id = menu.food_id
GROUP BY menu.food_name
ORDER BY no_of_dish_ordered ASC;
```

✅ Expected result:
| **food_name**                                     | **no_of_dish_ordered** |
|---------------------------------------------------|------------------------|
| Fried Chicken Wing                                | 47                     |
| Teh Tarik (Pulled Milk Tea)                       | 48                     |
| Sambal Sotong Extra (Spicy Squid Sambal)          | 48                     |
| Nasi Lemak Telur Mata (Egg Nasi Lemak)            | 51                     |
| Nasi Lemak Sotong (Squid Sambal Nasi Lemak)       | 53                     |
| Nasi Lemak Ayam Goreng (Fried Chicken Nasi Lemak) | 53                     |

</details>

### 5. What is the total revenue made by the restaurant?

📌 **Business Note:** Revenue tracking is the foundation of every financial report and is typically the first metric reviewed in monthly Profit & Loss.

- **Step 1:** Use the `uptown_nasi_lemak.orders` table to retrieve the order quantity and unit price of food.
- **Step 2:** Mutiply `quantity` and `unit_price` then apply `SUM` to add up revenue from all rows.

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT SUM(quantity * unit_price) AS total_revenue
FROM uptown_nasi_lemak.orders
```

✅ Expected result:
| **total_revenue** |
|-------------------|
| 3894.30           |

</details>

### 6. What is the total number of orders from each order channel? Sort results by the highest number of orders.

We want to know how many orders came from Dine-In, Takeaway, and GrabFood. 

- **Step 1:** Join `uptown_nasi_lemak.orders` with `uptown_nasi_lemak.order_channels` using `channel_id`.
- **Step 2:** Count how many `order_id` values appear for each channel.
- **Step 3:** Group by `channel_name` and sort results.

📌 **Business Note:** Splitting by channel helps businesses evaluate the ROI of delivery partnerships and optimize staff allocation across delivery vs. dine-in vs. takeaway.

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

### 7. How many orders don’t have a customer_id recorded? (NULL handling)

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT *
FROM uptown_nasi_lemak.orders AS orders
WHERE customer_id IS NULL;
```

✅ Expected result:  
| **order_id** | **customer_id** | **order_date** | **food_id** | **channel_id** | **quantity** | **unit_price** |
|--------------|-----------------|----------------|-------------|----------------|--------------|----------------|
| 13           | null            | 2025-01-04     | F01         | 1              | 1            | 12.20          |
| 43           | null            | 2025-01-13     | F01         | 1              | 1            | 12.20          |
| 195          | null            | 2025-01-22     | F05         | 2              | 1            | 18.00          |

</details>

---


## 🔥 Advanced (Level 8–15)

### 8. Which customer spent the most in total?

📈 **Corporate Insight:** This is useful in sales in identify the **highest revenue-generating customer**. Businesses can then analyse their spending behavior and design loyalty programs *(in this case, membership cards which they stamp and you get free Nasi Lemak! 🍚)*, targeted campaigns, or premium offers to maximize retention.

- **Step 1:** Use `uptown_nasi_lemak.orders` to get the spending per order.
- **Step 2:** Group by `customer_id` to calculate total spending.
- **Step 3:** Order results by `total_spent` in descending order and select the **top** customer.

<details> 
<summary> ▶️ Show solution 💡</summary>

```sql
SELECT 
	customer_id,
  SUM(quantity*unit_price) AS total_spent
FROM uptown_nasi_lemak.orders
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 1;
```

✅ Expected result: 
| **customer_id** | **total_spent** |
|-----------------|-----------------|
| C007            | 176.20          |

</details>

### 9. Which dish generated the most revenue?

📈 **Corporate Insight:** Knowing the top-earning dish helps restaurants decide what to feature on menus, run promotions for, or ensure that supply is never short.

- **Step 1:** Join `uptown_nasi_lemak.orders` with `uptown_nasi_lemak.menu`.
- **Step 2:** Group by `food_name`.
- **Step 3:** Order revenue in descending order (highest) and pick the top result.

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT 
	menu.food_name,
  SUM(orders.quantity*orders.unit_price) AS highest_revenue_generated
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

### 10. What is the average order value (AOV) for each channel? Round to the nearest 2 decimal points.

- **Step 1:** Join `uptown_nasi_lemak.orders` and `uptown_nasi_lemak.order_channels` to link orders with channels.
- **Step 2:** Mutiply `quantity` and `unit_price` to retrieve order values.
- **Step 3:** Apply `AVG` on order values and round to 2 decimals for readability.
- **Step 4:** Order results to easily see which channel has the highest AOV.

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT 
  channels.channel_name,
  ROUND(AVG(orders.quantity*unit_price),2) AS avg_order_value
FROM uptown_nasi_lemak.orders AS orders
INNER JOIN uptown_nasi_lemak.order_channels AS channels
  ON orders.channel_id = channels.channel_id
GROUP BY channels.channel_name
ORDER BY avg_order_value DESC;
```

DOUBLE CHECK SOLUTION

✅ Expected result:
| **channel_name** | **avg_order_value** |
|------------------|---------------------|
| Takeaway         | 15.48               |
| GrabFood         | 12.84               |
| Dine-In          | 10.79               |

</details>

📈 **Corporate Insight:** Average order value (AOV) is a key business metric. It helps identify which sales channels (e.g., dine-in, takeaway, delivery) bring in higher-value customers. Companies can then prioritize or optimize the most profitable channels.

### 11. Which customer used all 3 order channels?

- **Step 1:** Select `customer_id` from `uptown_nasi_lemak.orders`.
- **Step 2:** Use `COUNT(DISTINCT channel_id) = 3` in `HAVING`.
- **Step 3:** Filter results where the count = 3.

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT COUNT(customer_id)
FROM uptown_nasi_lemak.orders
HAVING COUNT(DISTINCT channel_id) = 3;
```

✅ Expected result:
| **count** |
|-----------|
| 297       |

</details>

### 12. Rank dishes by the number of times they were ordered. Use RANK(), DENSE_RANK(), and ROW_NUMBER() to demonstrate the differences in ranking when multiple dishes have the same order count.


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
  ROW_NUMBER() OVER (ORDER BY order_count DESC) AS row_number_seq
FROM dishes_popularity;
```

✅ Expected result:
| **food_name**                                     | **order_count** | **rank_seq** | **dense_rank_seq** | **row_number_seq** |
|---------------------------------------------------|-----------------|--------------|--------------------|--------------------|
| Nasi Lemak Sotong (Squid Sambal Nasi Lemak)       | 53              | 1            | 1                  | 1                  |
| Nasi Lemak Ayam Goreng (Fried Chicken Nasi Lemak) | 53              | 1            | 1                  | 2                  |
| Nasi Lemak Telur Mata (Egg Nasi Lemak)            | 51              | 3            | 2                  | 3                  |
| Teh Tarik (Pulled Milk Tea)                       | 48              | 4            | 3                  | 4                  |
| Sambal Sotong Extra (Spicy Squid Sambal)          | 48              | 4            | 3                  | 5                  |
| Fried Chicken Wing                                | 47              | 6            | 4                  | 6                  |


</details>

### 13. Within each channel, rank the top 2 customers by their total spend. If there are ties, customers should receive the same rank, and the next rank should not be skipped. Use the appropriate ranking window function.

<details> 
<summary> ▶️ Show solution</summary>

```sql
WITH customer_total_spending AS (
  SELECT
    channels.channel_name,
    orders.customer_id,
    SUM(orders.quantity*orders.unit_price) AS total_spend
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

### 14. Calculate the monthly revenue and show both the running total to date and the month-over-month percentage change.

<details> 
<summary> ▶️ Show solution</summary>

```sql
WITH revenue_by_mth AS (
  SELECT
    TO_CHAR(order_date, 'YYYY-MM') AS order_mth,
    SUM(quantity*unit_price) AS total_revenue
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

## Bonus Questions

Which customer placed the earliest order in the dataset?
Find all customers who ordered more than once on the same day.
For each dish, what is the average price ordered (useful if discounts existed)?
Which dish was ordered by the largest number of unique customers?
Show the top 5 customers by number of orders.


---

Good job! You've completed the tutorials. Give yourself a pat on the back. 🎉

Now it’s time to put your skills to the test with the Assignment!
