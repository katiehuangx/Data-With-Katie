# Ems Coffee

The `orders` data are in January 2026 only.

## Questions

How busy was the café — how many orders did we actually serve and how much money did the café bring in?
How much money did the café bring in during the month?
Who are our regulars vs one-time visitors — how many orders did each customer place?
What are customers actually drinking — which items are ordered the most?
Are there peak days — which days bring in the most revenue?
Who are our best customers — which customers spend the most overall?
On average, how much does a customer spend each time they order?
Does each customer have a “usual” — what’s the most frequently ordered drink per customer?
Are there bulk buyers — how many orders have unusually large quantities?
Which drinks are our money-makers — not just popular, but generating the most revenue?
How many of our customers are currently members, and how many have dropped off or never joined?
Are members actually valuable — how much revenue comes from members vs non-members?
Do members spend more when they order, or is it about the same?
Do members come back more often than non-members?
Does membership change behaviour — do customers order more after becoming members?
How long does it usually take for a customer to “convert” into a member?
When customers stop being members, do they slowly stop ordering too?
Who are the true VIPs — our top 5 highest-spending customers?
Are we relying too much on a few customers — how much revenue comes from our top 20%?
Do we have a retention problem — how many customers only ordered once and never came back?
Do early members behave differently — are long-time members more valuable than newer ones?

## Let's Solve Them Together

### 1. How busy was the café — how many orders did we actually serve and how much money did the café bring in?

<details> 
<summary> ▶️ Show solution</summary>

```sql
SELECT 
	COUNT(orders.order_id) AS total_orders,
    SUM(orders.quantity * menu.price) AS total_revenue
FROM orders
INNER JOIN menu
	ON orders.menu_id = menu.menu_id;
```

✅ Expected result:
| total_orders 	| total_revenue 	|
|--------------	|---------------	|
| 150          	| 3957.10       	|

</details>


### 3. Who are our regulars vs one-time visitors — how many orders did each customer place?

This can be an open-ended question as in you can sort the 




### 4. What are customers actually drinking — which items are ordered the most?
### 5. Are there peak days — which days bring in the most revenue?
### 6. Who are our best customers — which customers spend the most overall?
### 7. On average, how much does a customer spend each time they order?
### 8. Does each customer have a “usual” — what’s the most frequently ordered drink per customer?
### 9. Are there bulk buyers — how many orders have unusually large quantities?
### 10. Which drinks are our money-makers — not just popular, but generating the most revenue?
### 11. How many of our customers are currently members, and how many have dropped off or never joined?
### 12. Are members actually valuable — how much revenue comes from members vs non-members?
### 13. Do members spend more when they order, or is it about the same?
### 14. Do members come back more often than non-members?
### 15. Does membership change behaviour — do customers order more after becoming members?
### 16. How long does it usually take for a customer to “convert” into a member?
### 17. When customers stop being members, do they slowly stop ordering too?
### 18. Who are the true VIPs — our top 5 highest-spending customers?
### 19. Are we relying too much on a few customers — how much revenue comes from our top 20%?
### 20. Do we have a retention problem — how many customers only ordered once and never came back?
### 21. Do early members behave differently — are long-time members more valuable than newer ones?

