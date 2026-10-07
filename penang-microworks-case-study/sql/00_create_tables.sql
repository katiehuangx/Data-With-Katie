-- Penang Microworks Sdn Bhd: case study 1 tables (PostgreSQL)
-- Run: psql penang_microworks -f sql/00_create_tables.sql

DROP TABLE IF EXISTS gl_actuals, gl_budget, sales_volume, accounts, departments, products CASCADE;  -- CASCADE also drops the views built on them

-- Master data (clean, so these get primary keys)
CREATE TABLE accounts (
    account_id     INT PRIMARY KEY,
    account_code   VARCHAR(10)  NOT NULL,
    account_name   VARCHAR(100) NOT NULL,
    account_type   VARCHAR(20)  NOT NULL,   -- Revenue, COGS, Opex
    fs_line        VARCHAR(50)  NOT NULL,   -- line on the P&L
    fs_sort_order  INT          NOT NULL    -- order of lines on the P&L
);

CREATE TABLE departments (
    department_id     INT PRIMARY KEY,
    cost_center_code  VARCHAR(10)  NOT NULL,
    department_name   VARCHAR(50)  NOT NULL
);

CREATE TABLE products (
    product_id      INT PRIMARY KEY,
    product_code    VARCHAR(20)  NOT NULL,
    product_name    VARCHAR(100) NOT NULL,
    product_family  VARCHAR(50)  NOT NULL
);

-- Raw GL extracts: no primary or foreign keys ON PURPOSE.
-- Real Oracle GL extracts arrive like this; the data quality checks find the problems.
-- Sign convention: debits positive, credits negative (revenue is negative).
CREATE TABLE gl_actuals (
    line_id        INT,
    month          DATE,           -- first day of the posting month
    account_id     INT,
    department_id  INT,            -- filled on opex lines only
    product_id     INT,            -- filled on revenue and cost of sales lines only
    amount         NUMERIC(14,2)
);

CREATE TABLE gl_budget (
    line_id        INT,
    month          DATE,
    account_id     INT,
    department_id  INT,
    product_id     INT,
    amount         NUMERIC(14,2)
);

-- Units and revenue by product for the price-volume-mix bridge.
-- Actual columns are NULL for Oct-Dec: those months haven't happened yet.
CREATE TABLE sales_volume (
    month           DATE,
    product_id      INT,
    actual_units    INT,
    actual_revenue  NUMERIC(14,2),
    budget_units    INT,
    budget_revenue  NUMERIC(14,2)
);
