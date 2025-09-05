# Tutorial 

This tutorial is designed as a gentle introduction to SQL using a fun, real-world dataset inspired by a local Malaysian restaurant, Uptown Nasi Lemak. 

*(I'm a Malaysian 🇲🇾 and I love Uptown Park's nasi lemak especially their fried chicken, or what we call "ayam goreng" in Malay.)*

The exercises are arranged in increasing difficulty, starting from basic queries (counting rows, selecting unique values) and gradually moving towards more complex problems (joins, aggregations, window functions).

Each question comes with a short explanation of the concept it teaches, so you can practice and build confidence step by step.

If you’d like to check your answers, solutions are available in:

## How to Use This Repo

- `README.md` → Questions + explanations + solutions (are hidden!) (practice without answers).  
- `solutions.sql` → Raw SQL queries (copy & run in db-fiddle).   

## 🌱 Beginner (Level 1–3)

**1. How many total orders were made?**
We’re simply counting all the rows in the `sales` table since each row represents one order. Give the result a meaningful column name like `sales_count` or `no_of_sales_orders`. 

<details> <summary> Show solution 💡 </summary>
```sql
SELECT COUNT(*) AS sales_count
FROM uptown_nasi_lemak.sales;
```
</details>

**2. What are the names of all menu items available?**
Usually, when we’re asked “names of all menu items”, we want to avoid the duplicates so using `DISTINCT` ensures we’re only getting the **unique menu items**.

```sql
SELECT DISTINCT food_name
FROM uptown_nasi_lemak.menu;
```

3. What is the total number of unique customers?
This teaches the difference between counting rows and counting unique values. Here we count distinct customer_ids to find the customer base size.

Give it a meaningful column name like “customers_count” or “no_of_customers”.

```sql
SELECT COUNT(DISTINCT customer_id) AS unique_customers_count
FROM uptown_nasi_lemak.sales;
```

🍜 Intermediate (Level 4–6)
4. How many times was each dish ordered?
Group by product_id or product_name and count the number of times each dish was ordered.

5. What is the total revenue made by the restaurant?
Join sales with menu, multiply quantity by price, and sum it.

6. What is the total number of orders from each order channel?
Join sales with order_channels and group by channel.

🔥 Advanced (Level 7–10)
7. Which customer spent the most in total?
Join sales + menu, group by customer_id, and sum the spending.

8. Which dish generated the most revenue?
Group by product_id, join with menu, and calculate total revenue per dish.

9. What is the average order value for each channel?
Join sales, menu, and order_channels, group by channel, and compute average spend per order.

10. Which customer used all 3 order channels?
For each customer_id, count how many distinct channels they used and filter for exactly 3.

