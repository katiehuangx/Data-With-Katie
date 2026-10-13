# 🔌 Penang Microworks: Where did Q3 profit go?

## Table of Contents

- [The story](#the-story)
- [Schema](#schema)
- [P&L at a glance](#pl-at-a-glance)
- [Case study questions](#case-study-questions)
- [Case study solution](#case-study-solution)

## The story

Q3 operating profit missed budget. This case study is the monthly variance analysis write-up that explains why, in SQL, an FS-format report and a short CFO memo.

Before any of the questions, the GL extract went through 7 data quality checks. See [data-quality.md](./data-quality.md).

## Schema

Six tables: three lookup tables (accounts, departments, products) and three fact tables (GL actuals, GL budget and monthly sales volume). The questions read actuals from `gl_actuals_clean`, a view of `gl_actuals` after the data quality adjustments.

```mermaid
erDiagram
    ACCOUNTS ||--o{ GL_ACTUALS : "posted to"
    ACCOUNTS ||--o{ GL_BUDGET : "budgeted on"
    DEPARTMENTS ||--o{ GL_ACTUALS : "charged to"
    DEPARTMENTS ||--o{ GL_BUDGET : "budgeted for"
    PRODUCTS ||--o{ GL_ACTUALS : "sold or made"
    PRODUCTS ||--o{ GL_BUDGET : "planned for"
    PRODUCTS ||--o{ SALES_VOLUME : "sold as"

    ACCOUNTS {
        int account_id PK
        string account_code
        string account_name
        string account_type
        string fs_line
        int fs_sort_order
    }
    DEPARTMENTS {
        int department_id PK
        string cost_center_code
        string department_name
    }
    PRODUCTS {
        int product_id PK
        string product_code
        string product_name
        string product_family
    }
    GL_ACTUALS {
        int line_id
        date month
        int account_id FK
        int department_id FK
        int product_id FK
        decimal amount
    }
    GL_BUDGET {
        int line_id
        date month
        int account_id FK
        int department_id FK
        int product_id FK
        decimal amount
    }
    SALES_VOLUME {
        date month
        int product_id FK
        int actual_units
        decimal actual_revenue
        int budget_units
        decimal budget_revenue
    }
```

## P&L at a glance

Clean actuals (`gl_actuals_clean`) against budget in FS format. All amounts in RM. A negative variance is bad for profit.

### Q3 (July to September 2026)

| P&L line | Actual | Budget | Variance | Var % |
| --- | ---: | ---: | ---: | ---: |
| **Revenue** | **24,183,231** | **25,058,385** | **-875,154** | **-3.5** |
| *Cost of sales* | | | | |
| &nbsp;&nbsp;&nbsp;&nbsp;Direct materials | 11,370,222 | 11,486,353 | 116,130 | 1.0 |
| &nbsp;&nbsp;&nbsp;&nbsp;Direct labour | 1,949,181 | 1,969,089 | 19,908 | 1.0 |
| &nbsp;&nbsp;&nbsp;&nbsp;Manufacturing overhead | 2,923,771 | 2,953,634 | 29,862 | 1.0 |
| **(-) Cost of sales** | **16,243,175** | **16,409,075** | **165,900** | **1.0** |
| **Gross profit** | **7,940,056** | **8,649,310** | **-709,254** | **-8.2** |
| *Operating expenses* | | | | |
| &nbsp;&nbsp;&nbsp;&nbsp;*Staff costs* | | | | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Engineering | 1,563,523 | 1,385,100 | -178,423 | -12.9 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Operations | 511,785 | 513,000 | 1,215 | 0.2 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sales & Marketing | 410,605 | 410,400 | -205 | 0.0 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;General and Administrative | 432,380 | 430,920 | -1,460 | -0.3 |
| &nbsp;&nbsp;&nbsp;&nbsp;Rental and utilities | 597,058 | 600,000 | 2,942 | 0.5 |
| &nbsp;&nbsp;&nbsp;&nbsp;Depreciation | 660,000 | 660,000 | 0 | 0.0 |
| &nbsp;&nbsp;&nbsp;&nbsp;Other operating expenses | 604,038 | 600,000 | -4,038 | -0.7 |
| **(-) Total operating expenses** | **4,779,389** | **4,599,420** | **-179,969** | **-3.9** |
| **Operating profit** | **3,160,668** | **4,049,890** | **-889,222** | **-22.0** |

### Year to date (January to September 2026)

| P&L line | Actual | Budget | Variance | Var % |
| --- | ---: | ---: | ---: | ---: |
| **Revenue** | **69,717,966** | **71,133,480** | **-1,415,514** | **-2.0** |
| *Cost of sales* | | | | |
| &nbsp;&nbsp;&nbsp;&nbsp;Direct materials | 32,466,442 | 32,606,420 | 139,978 | 0.4 |
| &nbsp;&nbsp;&nbsp;&nbsp;Direct labour | 5,565,676 | 5,589,672 | 23,996 | 0.4 |
| &nbsp;&nbsp;&nbsp;&nbsp;Manufacturing overhead | 8,348,514 | 8,384,508 | 35,994 | 0.4 |
| **(-) Cost of sales** | **46,380,632** | **46,580,600** | **199,968** | **0.4** |
| **Gross profit** | **23,337,335** | **24,552,880** | **-1,215,545** | **-5.0** |
| *Operating expenses* | | | | |
| &nbsp;&nbsp;&nbsp;&nbsp;*Staff costs* | | | | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Engineering | 4,400,741 | 4,155,300 | -245,441 | -5.9 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Operations | 1,541,538 | 1,539,000 | -2,538 | -0.2 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sales & Marketing | 1,232,937 | 1,231,200 | -1,737 | -0.1 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;General and Administrative | 1,293,341 | 1,292,760 | -581 | 0.0 |
| &nbsp;&nbsp;&nbsp;&nbsp;Rental and utilities | 1,824,110 | 1,800,000 | -24,110 | -1.3 |
| &nbsp;&nbsp;&nbsp;&nbsp;Depreciation | 1,980,000 | 1,980,000 | 0 | 0.0 |
| &nbsp;&nbsp;&nbsp;&nbsp;Other operating expenses | 1,969,595 | 1,800,000 | -169,595 | -9.4 |
| **(-) Total operating expenses** | **14,242,262** | **13,798,260** | **-444,002** | **-3.2** |
| **Operating profit** | **9,095,073** | **10,754,620** | **-1,659,547** | **-15.4** |

***

All amounts are in Malaysian Ringgit (RM).

Definitions used throughout:
- **Actuals** come from `gl_actuals_clean`, not `gl_actuals`. It has the adjusting entries and leaves out the 3 lines on hold.
- **Budget** comes from `gl_budget`.
- **Q3** = July to September 2026. **YTD** = January to September 2026.
- **Sign convention:** the GL stores debits as positive and credits as negative, so revenue is negative and costs are positive. Flip the sign (`-SUM(amount)`) to show revenue and profit as positive numbers.
- **Variance** = actual − budget, shown so that a positive number is good for profit and a negative number is bad: revenue above budget is positive, costs above budget are negative.
- **Gross profit** = revenue − cost of sales. **Operating profit** = gross profit − operating expenses.
- Revenue and cost of sales lines carry a `product_id`. Opex lines carry a `department_id`.

## Case Study Questions

### Core Questions

1. [Revenue by Product Family](#1-revenue-by-product-family): Which product families drove the revenue miss? Return product family, Q3 actual revenue, budget revenue, variance (RM) and variance %, sorted by the most negative variance first.

2. [Gross Margin by Product Family](#2-gross-margin-by-product-family): Q1 showed revenue shifting away from sensor modules towards connectivity boards. Did that shift hurt profit more than the revenue figure suggests? Return product family, actual and budget gross profit, and actual and budget gross margin % (rounded to 1 decimal place).

3. [Opex by Cost Center](#3-opex-by-cost-center): Which departments overspent in Q3? Return department name, actual opex, budget opex, variance (RM) and variance %, sorted by the biggest overspend first.

4. [Monthly Trend](#4-monthly-trend): Was Q3 a sudden drop or a slow slide? For each month January to September, return actual and budget operating profit, the monthly variance, and the YTD cumulative variance (using a window function).

### Advanced Questions

5. [Price-Volume-Mix Bridge](#5-price-volume-mix-bridge): Split the Q3 product revenue variance into price, volume and mix effects by product, using `sales_volume`. Return product code, price effect, volume effect, mix effect and total variance, plus a total row. The three effects should add up to actual − budget revenue.

   | Effect | Formula (per product) |
   | --- | --- |
   | Price | (actual price − budget price) × actual units |
   | Volume | (total actual units × budget share of units − budget units) × budget price |
   | Mix | (actual units − total actual units × budget share of units) × budget price |

   Price = revenue ÷ units. Budget share of units = the product's budget units ÷ total budget units.

6. [Operating Profit Bridge](#6-operating-profit-bridge): Walk from Q3 budget operating profit to actual operating profit in one table, ready for a waterfall chart. Return one row per step: budget operating profit, price, volume, mix, sales returns (account 4100, which isn't in `sales_volume`), cost of sales, each opex fs_line, and actual operating profit. Each step should show its RM impact, and the steps should add up from budget to actual.

7. [Full-Year Forecast](#7-full-year-forecast): Where will FY2026 land? Build a simple forecast as YTD actuals (Jan–Sep) plus budget for October to December. Return revenue, gross profit, opex and operating profit for the forecast and the full-year budget, with the variance between them.

8. [CFO Memo](#8-cfo-memo): Using your answers above, write a short memo (no more than 200 words) to the CFO: how much Q3 missed by, the top three drivers with their RM impact, and what the forecast means for the full year.

## Case Study Solution

### 1. Revenue by Product Family

Which product families drove the revenue miss? Return product family, Q3 actual revenue, budget revenue, variance (RM) and variance %, sorted by the most negative variance first.

```sql
WITH revenue_actuals AS (
    SELECT
        p.product_family,
        -SUM(g.amount) AS actual_revenue
    FROM gl_actuals_clean AS g
    INNER JOIN accounts AS a
        ON g.account_id = a.account_id
    INNER JOIN products AS p
        ON g.product_id = p.product_id
    WHERE a.account_type = 'Revenue'
        AND (month >= '2026-07-01' AND month <= '2026-09-30')
    GROUP BY p.product_family
)
, revenue_budget AS (
    SELECT
        p.product_family,
        -SUM(b.amount) AS budget_revenue
    FROM gl_budget AS b
    INNER JOIN accounts AS a
        ON b.account_id = a.account_id
    INNER JOIN products AS p
        ON b.product_id = p.product_id
    WHERE a.account_type = 'Revenue'
        AND (month >= '2026-07-01' AND month <= '2026-09-30')
    GROUP BY p.product_family
)

SELECT 
    ra.product_family,
    ra.actual_revenue,
    rb.budget_revenue,
    ra.actual_revenue - rb.budget_revenue AS variance,
    ROUND(100.0 * ((ra.actual_revenue - rb.budget_revenue)/rb.budget_revenue),1) AS variance_pct
FROM revenue_actuals AS ra
INNER JOIN revenue_budget AS rb
    ON ra.product_family = rb.product_family
ORDER BY variance ASC;
```

**✅ Result:**
```
   product_family    | actual_revenue | budget_revenue |  variance   | variance_pct 
---------------------+----------------+----------------+-------------+--------------
 Sensor modules      |     8565644.60 |     9636660.00 | -1071015.40 |        -11.1
 Power modules       |     8803116.29 |     9207000.00 |  -403883.71 |         -4.4
 Connectivity boards |     6814470.36 |     6214725.00 |   599745.36 |          9.7
(3 rows)
```

**📊 Commentary:** Total actual and budget revenue tie to the P&L figures. Revenue missed budget by RM875k, but that's the net figure. 

When we drill down by product family, sensor modules alone missed by RM1.07m (-11.1%) and power modules by RM0.4k (-4.4%). Connectivity boards beat budget by RM600k (9.7%) which offset the two negatives and made the total variance smaller. 

### 2. Gross Margin by Product Family

Q1 showed revenue shifting away from sensor modules towards connectivity boards. Did that shift hurt profit more than the revenue figure suggests? Return product family, actual and budget gross profit, and actual and budget gross margin % (rounded to 1 decimal place).

```sql

```


**✅ Result:**

### 3. Opex by Cost Center

Which departments overspent in Q3? Return department name, actual opex, budget opex, variance (RM) and variance %, sorted by the biggest overspend first.

```sql

```


**✅ Result:**

### 4. Monthly Trend

Was Q3 a sudden drop or a slow slide? For each month January to September, return actual and budget operating profit, the monthly variance, and the YTD cumulative variance (using a window function).

```sql

```


**✅ Result:**

### 5. Price-Volume-Mix Bridge

Split the Q3 product revenue variance into price, volume and mix effects by product, using `sales_volume`. Return product code, price effect, volume effect, mix effect and total variance, plus a total row. The three effects should add up to actual − budget revenue.

| Effect | Formula (per product) |
| --- | --- |
| Price | (actual price − budget price) × actual units |
| Volume | (total actual units × budget share of units − budget units) × budget price |
| Mix | (actual units − total actual units × budget share of units) × budget price |

Price = revenue ÷ units. Budget share of units = the product's budget units ÷ total budget units.

```sql

```


**✅ Result:**

### 6. Operating Profit Bridge

Walk from Q3 budget operating profit to actual operating profit in one table, ready for a waterfall chart. Return one row per step: budget operating profit, price, volume, mix, sales returns (account 4100, which isn't in `sales_volume`), cost of sales, each opex fs_line, and actual operating profit. Each step should show its RM impact, and the steps should add up from budget to actual.

```sql

```


**✅ Result:**

### 7. Full-Year Forecast

Where will FY2026 land? Build a simple forecast as YTD actuals (Jan–Sep) plus budget for October to December. Return revenue, gross profit, opex and operating profit for the forecast and the full-year budget, with the variance between them.

```sql

```


**✅ Result:**

### 8. CFO Memo

Using your answers above, write a short memo (no more than 200 words) to the CFO: how much Q3 missed by, the top three drivers with their RM impact, and what the forecast means for the full year.

**✅ Memo:**
