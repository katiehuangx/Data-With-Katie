# 🔌 Penang Microworks: Where did Q3 profit go?

## Table of Contents

- [The story](#the-story)
- [P&L at a Glance](#pl-at-a-glance)
- [Case Study Questions](#case-study-questions)
- [Case Study Solution](#case-study-solution)

## The story

Q3 operating profit missed budget. This case study is the monthly variance analysis write-up that explains why, in SQL, an FS-format report and a short CFO memo.
- **Why first:** variance analysis is the most common FP&A deliverable, so it's what Penang hiring managers will recognise first
- **What it shows:** FS formatting in SQL, variance logic with sign conventions, a price-volume-mix bridge, a simple forecast and written commentary
- **Scope:** small enough to finish in a few weeks; working capital and standard costing are separate case studies in the series

Before any of the questions, the GL extract went through seven data quality checks. See [data-quality.md](./data-quality.md).

## P&L at a Glance

Clean actuals (`gl_actuals_clean`) against budget, in FS format. All amounts in RM. A negative variance is bad for profit.

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
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;G&A | 432,380 | 430,920 | -1,460 | -0.3 |
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
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;G&A | 1,293,341 | 1,292,760 | -581 | 0.0 |
| &nbsp;&nbsp;&nbsp;&nbsp;Rental and utilities | 1,824,110 | 1,800,000 | -24,110 | -1.3 |
| &nbsp;&nbsp;&nbsp;&nbsp;Depreciation | 1,980,000 | 1,980,000 | 0 | 0.0 |
| &nbsp;&nbsp;&nbsp;&nbsp;Other operating expenses | 1,969,595 | 1,800,000 | -169,595 | -9.4 |
| **(-) Total operating expenses** | **14,242,262** | **13,798,260** | **-444,002** | **-3.2** |
| **Operating profit** | **9,095,073** | **10,754,620** | **-1,659,547** | **-15.4** |

***

All amounts are in Malaysian Ringgit (RM).

Definitions used throughout:
- **Actuals** come from `gl_actuals_clean`, never `gl_actuals`. It has the adjusting entries and leaves out the 3 lines on hold.
- **Budget** comes from `gl_budget`.
- **Q3** = July to September 2026. **YTD** = January to September 2026.
- **Sign convention:** the GL stores debits as positive and credits as negative, so revenue is negative and costs are positive. Flip the sign (`-SUM(amount)`) to show revenue and profit as positive numbers.
- **Variance** = actual − budget, shown so that a positive number is good for profit and a negative number is bad: revenue above budget is positive, costs above budget are negative.
- **Gross profit** = revenue − cost of sales. **Operating profit** = gross profit − operating expenses.
- Revenue and cost of sales lines carry a `product_id`. Opex lines carry a `department_id`.

## Case Study Questions

### Core Questions

1. [Q3 at a Glance](#1-q3-at-a-glance): How far did Q3 operating profit miss budget? Return revenue, cost of sales, gross profit, operating expenses and operating profit for Q3, with actual, budget, variance (RM) and variance % (rounded to 1 decimal place).

2. [Revenue by Product Family](#2-revenue-by-product-family): Which product families drove the revenue miss? Return product family, Q3 actual revenue, budget revenue, variance (RM) and variance %, sorted by the most negative variance first.

3. [Gross Margin by Product Family](#3-gross-margin-by-product-family): Revenue is only half the story. Did the mix shift towards lower-margin products? Return product family, actual and budget gross profit, and actual and budget gross margin % (rounded to 1 decimal place).

4. [Opex by Cost Center](#4-opex-by-cost-center): Which departments overspent in Q3? Return department name, actual opex, budget opex, variance (RM) and variance %, sorted by the biggest overspend first.

5. [Monthly Trend](#5-monthly-trend): Was Q3 a sudden drop or a slow slide? For each month January to September, return actual and budget operating profit, the monthly variance, and the YTD cumulative variance (using a window function).

### Advanced Questions

6. [Price-Volume-Mix Bridge](#6-price-volume-mix-bridge): Split the Q3 product revenue variance into price, volume and mix effects by product, using `sales_volume`. Return product code, price effect, volume effect, mix effect and total variance, plus a total row. The three effects should add up to actual − budget revenue.

   | Effect | Formula (per product) |
   | --- | --- |
   | Price | (actual price − budget price) × actual units |
   | Volume | (total actual units × budget share of units − budget units) × budget price |
   | Mix | (actual units − total actual units × budget share of units) × budget price |

   Price = revenue ÷ units. Budget share of units = the product's budget units ÷ total budget units.

7. [Operating Profit Bridge](#7-operating-profit-bridge): Walk from Q3 budget operating profit to actual operating profit in one table, ready for a waterfall chart. Return one row per step: budget operating profit, price, volume, mix, sales returns (account 4100, which isn't in `sales_volume`), cost of sales, each opex fs_line, and actual operating profit. Each step should show its RM impact, and the steps should add up from budget to actual.

8. [Full-Year Forecast](#8-full-year-forecast): Where will FY2026 land? Build a simple forecast as YTD actuals (Jan–Sep) plus budget for October to December. Return revenue, gross profit, opex and operating profit for the forecast and the full-year budget, with the variance between them.

9. [CFO Memo](#9-cfo-memo): Using your answers above, write a short memo (no more than 200 words) to the CFO: how much Q3 missed by, the top three drivers with their RM impact, and what the forecast means for the full year.

## Case Study Solution


