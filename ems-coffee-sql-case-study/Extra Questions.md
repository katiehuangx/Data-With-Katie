# ☕️ Ems Coffee SQL Case Study - Extra Questions

### 11. Tenure vs. Spend 

Do long-tenured members spend more than newer members? 

Return tenure cohort (grouped by membership start month), number of customers, and average total spend per customer (rounded to 2 decimal places) sorted chronologically by cohort join month.

*(Note: all memberships began within a single 4-month window (Jan–Apr 2025), so cohort tenure gaps are narrow — at most ~3 months between the earliest and latest cohort. Treat this as a limited test of the tenure-spend relationship rather than a definitive one.)*

```sql
SELECT 
    TO_CHAR(customers.membership_start_date, 'YYYY-MM') AS mth_yr,
    COUNT(DISTINCT customers.customer_id) AS num_of_distinct_members,
    SUM(orders.quantity * menu.price) AS total_spend,
    ROUND(
        SUM(orders.quantity * menu.price) / COUNT(DISTINCT customers.customer_id)
        , 2) AS avg_spend_per_customer
FROM orders
INNER JOIN customers
    ON orders.customer_id = customers.customer_id
INNER JOIN menu
    ON orders.menu_id = menu.menu_id
WHERE customers.membership_start_date IS NOT NULL
GROUP BY TO_CHAR(customers.membership_start_date, 'YYYY-MM')
ORDER BY mth_yr;
```

**✅ Result:**
| mth_yr  | num_of_distinct_members | total_spend | avg_spend_per_customer |
|---------|-------------------------|-------------|------------------------|
| 2025-01 |                       7 |     2007.20 |                 286.74 |
| 2025-02 |                       6 |     1747.70 |                 291.28 |
| 2025-03 |                       6 |     1778.60 |                 296.43 |
| 2025-04 |                       5 |     1365.70 |                 273.14 |

**💡 Commentary:**
Average spend per customer is fairly flat across all four cohorts from RM273 to RM296 with no obvious upward or downward trend. February and March spend slightly more than January which is the opposite of what "longer tenure = more spend" would predict.

*(Katie (author)'s note: I'm aware that this isn't a strong test of the question due to the generation of the dataset. All 24 member joined within the same 4-month window (Jan–Apr 2025). There's not much runway for a spend difference to show up even if one exists in reality.)*