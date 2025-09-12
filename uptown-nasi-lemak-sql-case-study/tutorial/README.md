# Tutorial 

This tutorial is a gentle introduction to SQL using a fun, real-world dataset inspired by a local Malaysian favourite: *Village Park Nasi Lemak*. 

*(I'm Malaysian 🇲🇾 and I love Village Park's nasi lemak with crispy fried chicken or what we call "ayam goreng" in Malay.)*

The exercises are arranged in increasing difficulty. We'll start with basic queries (**counting rows, selecting unique values**) and gradually move into more advanced problems (**joins, aggregations, and window functions**). 

Each question comes with a short explanation of the concept it teaches, so you can practice and build confidence step by step. 😉

If you’d like to:
- check your answers → click the **▶️ Show solution 💡** toggle under each question to expand the solution. 
- practice on your own or add into your portfolio → use the questions_only.md and insert your own solutions.

---

## 🌱 Beginner (Level 1–3)

### 1. How many total orders were made?

We’re simply counting all the rows in the `sales` table since each row represents one order. 

- **Step 1:** Identify the table where the data is from → `uptown_nasi_lemak.sales`. 
<p align="left">
  <img src="erd.png" alt="Uptown Nasi Lemak ERD" width="700"/>
</p>

*(Link to Entity Relationship (ER) diagram: [here](https://github.com/katiehuangx/Data-With-Katie/blob/main/uptown-nasi-lemak-sql-case-study/assets/erd.png))*

- **Step 2:** Use `COUNT(*)` or `COUNT(order_id)` to count the rows. 
- **Step 3:** Give the result a meaningful column name `AS sales_count`.

<details> 
<summary> ▶️ Show solution 💡 (click to expand) </summary>

```sql
SELECT COUNT(*) AS sales_count
FROM uptown_nasi_lemak.sales;
```

✅ Expected result: 36
</details>


### 2. What are the names of all menu items available?

We want to list all the menu items sold. Since duplicates don’t add value here, we use `DISTINCT` so each food name shows only once.  

- **Step 1:** Identify table where menu items are stored → `uptown_nasi_lemak.menu`.  
- **Step 2:** Apply `DISTINCT` on `food_name` to remove duplicates.

<details> 
<summary> ▶️ Show solution </summary>

```sql
SELECT DISTINCT food_name
FROM uptown_nasi_lemak.menu;
```

✅ Expected result: 
| food_name              |
| ---------------------- |
| Nasi Lemak Ayam Goreng |
| Nasi Lemak Sotong      |
| Nasi Lemak Telur Mata  |

</details>


### 3. What is the total number of unique customers?

We’re finding how many different customers placed an order. That means counting distinct `customer_id`s rather than rows.

- **Step 1:** Identify table with customer IDs → `uptown_nasi_lemak.sales`.
- **Step 2:** Use `COUNT(DISTINCT customer_id)` to count unique values.

<details> 
<summary> ▶️ Show solution </summary>

```sql
SELECT COUNT(DISTINCT customer_id) AS customer_count
FROM uptown_nasi_lemak.sales;
```

✅ Expected result: 10
</details>

---

## 🍜 Intermediate (Level 4–6)

### 4. How many times was each dish ordered?  
We want to see the popularity of each menu item. To do that, we group by dish name and count how many times it was ordered.  

💡 **Tip:** It might feel easier to group by `food_id` and just output IDs. But in real-world reporting, IDs aren’t meaningful to business users. Showing the actual **dish names** makes the output clearer and more useful.  

- **Step 1:** Identify the tables needed → `uptown_nasi_lemak.sales` and `uptown_nasi_lemak.menu`.  
- **Step 2:** Join them on `food_id` to match orders with dish names.  
- **Step 3:** Use `COUNT(order_id)` grouped by `food_name` to find the number of times each dish was ordered.  
- **Step 4:** Sort the results in ascending order by the count.  

<details> 
<summary> ▶️ Show solution </summary>

```sql
SELECT 
	menu.food_name,
  COUNT(sales.order_id) AS no_of_dish_ordered
FROM uptown_nasi_lemak.sales AS sales
INNER JOIN uptown_nasi_lemak.menu AS menu
	ON sales.food_id = menu.food_id
GROUP BY menu.food_name
ORDER BY no_of_dish_ordered ASC;
```

✅ Expected result:
| food_name | no_of_dish_ordered | 
| ---------------------- | --------------- | 
| Nasi Lemak Ayam Goreng | 11 | 
| Nasi Lemak Sotong | 12 | 
| Nasi Lemak Telur Mata | 13 |

</details>

### 5. What is the total revenue made by the restaurant?
Join sales with menu and sum the price.

<details> 
<summary> ▶️ Show solution 💡</summary>

```sql
SELECT SUM(menu.price) AS revenue
FROM uptown_nasi_lemak.sales AS sales
INNER JOIN uptown_nasi_lemak.menu AS menu
	ON sales.food_id = menu.food_id;
```

✅ Expected result: 10
</details>

### 6. What is the total number of orders from each order channel? 

Join sales with order_channels and group by channel.

<details> 
<summary> ▶️ Show solution 💡</summary>

```sql
SELECT 
  channels.channel_name,
	COUNT(sales.order_id) AS no_of_orders
FROM uptown_nasi_lemak.sales AS sales
INNER JOIN uptown_nasi_lemak.order_channels AS channels
	ON sales.channel_id = channels.channel_id
GROUP BY channels.channel_name
ORDER BY no_of_orders ASC;
```

✅ Expected result:  
| channel_name | no_of_orders |
| ------------ | ------------ |
| GrabFood     | 10           |
| Takeaway     | 11           |
| Dine-In      | 15           |

</details>

---

## 🔥 Advanced (Level 7–10)

### 7. Which customer spent the most in total?
Output the customer ID with total spent. 

Join sales + menu, group by customer_id, and sum the spending.

<details> 
<summary> ▶️ Show solution 💡</summary>

```sql
SELECT 
	sales.customer_id,
  SUM(menu.price) AS total_spent
FROM uptown_nasi_lemak.sales AS sales
INNER JOIN uptown_nasi_lemak.menu AS menu
	ON sales.food_id = menu.food_id
GROUP BY sales.customer_id
ORDER BY total_spent DESC
LIMIT 1;
```

✅ Expected result: 
| customer_id | total_spent |
| ----------- | ----------- |
| A           | 77          |
</details>

### 8. Which dish generated the most revenue?
Group by product_id, join with menu, and calculate total revenue per dish.

<details> 
<summary> ▶️ Show solution 💡</summary>

```sql
SELECT 
	menu.food_name,
    SUM(menu.price) AS most_revenue_generated
FROM uptown_nasi_lemak.sales AS sales
INNER JOIN uptown_nasi_lemak.menu AS menu
	ON sales.food_id = menu.food_id
GROUP BY menu.food_name
ORDER BY most_revenue_generated DESC
LIMIT 1;
```

✅ Expected result: 
| food_name         | most_revenue_generated |
| ----------------- | ---------------------- |
| Nasi Lemak Sotong | 180                    |
</details>

### 9. What is the average order value for each channel?
Join sales, menu, and order_channels, group by channel, and compute average spend per order.

<details> 
<summary> ▶️ Show solution 💡</summary>

```sql
WITH order_channel_prices AS (
SELECT 
	channels.channel_name,
    sales.order_id,
  	menu.price
FROM uptown_nasi_lemak.sales AS sales
INNER JOIN uptown_nasi_lemak.menu AS menu
	ON sales.food_id = menu.food_id
INNER JOIN uptown_nasi_lemak.order_channels AS channels
	ON sales.channel_id = channels.channel_id
)

SELECT
	channel_name,
    ROUND(AVG(price),2) AS avg_order_value
FROM order_channel_prices
GROUP BY channel_name
ORDER BY avg_order_value DESC;
```

✅ Expected result:
| channel_name | avg_order_value |
| ------------ | ---------------- |
| Dine-In      | 12.33            |
| Takeaway     | 11.73            |
| GrabFood     | 10.20            |
</details>

### 10. Which customer used all 3 order channels?
For each customer_id, count how many distinct channels they used and filter for exactly 3.

<details> 
<summary> ▶️ Show solution 💡</summary>

```sql
SELECT COUNT(DISTINCT customer_id) AS customer_count
FROM uptown_nasi_lemak.sales;
```

✅ Expected result: 10
</details>
