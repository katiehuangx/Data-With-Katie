-- Load the CSVs into the tables.
-- Run from the case study folder (paths are relative):
--   psql penang_microworks -f sql/01_load_data.sql
-- Empty CSV fields load as NULL.

\copy accounts     FROM 'data/accounts.csv'     WITH (FORMAT csv, HEADER true)
\copy departments  FROM 'data/departments.csv'  WITH (FORMAT csv, HEADER true)
\copy products     FROM 'data/products.csv'     WITH (FORMAT csv, HEADER true)
\copy gl_actuals   FROM 'data/gl_actuals.csv'   WITH (FORMAT csv, HEADER true)
\copy gl_budget    FROM 'data/gl_budget.csv'    WITH (FORMAT csv, HEADER true)
\copy sales_volume FROM 'data/sales_volume.csv' WITH (FORMAT csv, HEADER true)

-- Quick row-count check
SELECT 'accounts' AS table_name, COUNT(*) AS row_count FROM accounts
UNION ALL SELECT 'departments', COUNT(*) FROM departments
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'gl_actuals', COUNT(*) FROM gl_actuals
UNION ALL SELECT 'gl_budget', COUNT(*) FROM gl_budget
UNION ALL SELECT 'sales_volume', COUNT(*) FROM sales_volume;
