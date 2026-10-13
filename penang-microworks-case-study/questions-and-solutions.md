# 🔌 Penang Microworks: Where did Q3 profit go?

## Table of Contents

- [The story](#the-story)
- [Case Study Questions](#case-study-questions)
- [Case Study Solution](#case-study-solution)

## The story

Q3 operating profit missed budget. This case study is the monthly variance pack that explains why, in SQL, an FS-format report and a short CFO memo.
- **Why first:** the variance pack is the most common FP&A deliverable, so it's what Penang hiring managers will recognise first
- **What it shows:** FS formatting in SQL, variance logic with sign conventions, a price-volume-mix bridge, a simple forecast and written commentary
- **Scope:** small enough to finish in a few weeks; working capital and standard costing are separate case studies in the series

Before any of the questions, the GL extract went through seven data quality checks. See [data-quality.md](./data-quality.md).

***

All amounts are in Malaysian Ringgit (RM).

Definitions used throughout:
- **Actuals** come from `gl_actuals_clean`, never `gl_actuals`. It has the adjusting entries and leaves out the 3 lines on hold.
- **Budget** comes from `gl_budget`.
- **Q3** = July to September 2026. **YTD** = January to September 2026.
- **Sign convention:** the GL stores debits as positive and credits as negative, so revenue is negative and costs are positive. Flip the sign (`-SUM(amount)`) to show revenue and profit as positive numbers.
- **Variance** = actual − budget, shown so that a positive number is good for profit. Label each variance **F** (favourable) or **U** (unfavourable): revenue above budget is F, costs above budget are U.
- **Gross profit** = revenue − cost of sales. **Operating profit** = gross profit − operating expenses.
- Revenue and cost of sales lines carry a `product_id`. Opex lines carry a `department_id`.

## Case Study Questions

### Core Questions

1. [Q3 at a Glance](#1-q3-at-a-glance): How far did Q3 operating profit miss budget? Return revenue, cost of sales, gross profit, operating expenses and operating profit for Q3, with actual, budget, variance (RM) and variance % (rounded to 1 decimal place).

2. [FS-Format P&L](#2-fs-format-pl): Build the Q3 P&L the way it would appear in a management pack. Return one row per `fs_line` in `fs_sort_order`, with **Gross profit** and **Operating profit** subtotal rows in the right places. Show actual, budget, variance (RM), variance % and an F/U label.

3. [Revenue by Product Family](#3-revenue-by-product-family): Which product families drove the revenue miss? Return product family, Q3 actual revenue, budget revenue, variance (RM) and variance %, sorted by the biggest unfavourable variance first.

4. [Gross Margin by Product Family](#4-gross-margin-by-product-family): Revenue is only half the story. Did the mix shift towards lower-margin products? Return product family, actual and budget gross profit, and actual and budget gross margin % (rounded to 1 decimal place).

5. [Opex by Cost Center](#5-opex-by-cost-center): Which departments overspent in Q3? Return department name, actual opex, budget opex, variance (RM), variance % and F/U label, sorted by the biggest overspend first.

6. [Monthly Trend](#6-monthly-trend): Was Q3 a sudden drop or a slow slide? For each month January to September, return actual and budget operating profit, the monthly variance, and the YTD cumulative variance (using a window function).

### Advanced Questions

7. [Price-Volume-Mix Bridge](#7-price-volume-mix-bridge): Split the Q3 product revenue variance into price, volume and mix effects by product, using `sales_volume`. Return product code, price effect, volume effect, mix effect and total variance, plus a total row. The three effects should add up to actual − budget revenue.

   | Effect | Formula (per product) |
   | --- | --- |
   | Price | (actual price − budget price) × actual units |
   | Volume | (total actual units × budget share of units − budget units) × budget price |
   | Mix | (actual units − total actual units × budget share of units) × budget price |

   Price = revenue ÷ units. Budget share of units = the product's budget units ÷ total budget units.

8. [Operating Profit Bridge](#8-operating-profit-bridge): Walk from Q3 budget operating profit to actual operating profit in one table, ready for a waterfall chart. Return one row per step: budget operating profit, price, volume, mix, sales returns (account 4100, which isn't in `sales_volume`), cost of sales, each opex fs_line, and actual operating profit. Each step should show its RM impact, and the steps should add up from budget to actual.

9. [Full-Year Forecast](#9-full-year-forecast): Where will FY2026 land? Build a simple forecast as YTD actuals (Jan–Sep) plus budget for October to December. Return revenue, gross profit, opex and operating profit for the forecast and the full-year budget, with the variance between them.

10. [CFO Memo](#10-cfo-memo): Using your answers above, write a short memo (no more than 200 words) to the CFO: how much Q3 missed by, the top three drivers with their RM impact, and what the forecast means for the full year.

## Case Study Solution

*Solutions to come.*
