
WITH duplicate_rows AS (
    SELECT line_id
    FROM gl_actuals
    WHERE month >= '2026-09-01'
        AND month < '2026-10-01'
    GROUP BY line_id
    HAVING COUNT(line_id) > 1
)

SELECT 
    g.line_id,
    g.month,
    a.account_code,
    a.account_name,
    a.account_type,
    d.department_name,
    g.amount
FROM gl_actuals AS g
INNER JOIN duplicate_rows AS r
    ON g.line_id = r.line_id
LEFT JOIN accounts AS a
    ON g.account_id = a.account_id
LEFT JOIN departments AS d
    ON g.department_id = d.department_id
WHERE a.account_type = 'Revenue';


-- {# SELECT
--     g.line_id,
--     g.month,
--     a.account_code,
--     a.account_name,
--     a.account_type,
--     d.department_name,
--     g.amount,
--     COUNT(g.line_id)
-- FROM gl_actuals as g
-- LEFT JOIN accounts as a
--     ON g.account_id = a.account_id
-- LEFT JOIN departments as d
--     ON g.department_id = d.department_id
-- WHERE g.month >= '2026-09-01'
--     AND g.month < '2026-10-01'
--     AND a.account_type = 'Revenue'
-- GROUP BY 
--     g.line_id,
--     g.month,
--     a.account_code,
--     a.account_name,
--     a.account_type,
--     d.department_name,
--     g.amount
-- HAVING COUNT(g.line_id) > 1; #}
