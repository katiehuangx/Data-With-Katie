WITH gl AS (
    SELECT
        g.month,
        -SUM(g.amount) AS gl_revenue
    FROM gl_actuals AS g
    INNER JOIN accounts AS a
        ON g.account_id = a.account_id
    WHERE g.account_id = 1                  -- 4000 Product sales
        AND g.month < '2026-10-01'
    GROUP BY g.month
)
, sv AS (
    SELECT 
        month,
        SUM(actual_revenue) AS sv_revenue
    FROM sales_volume AS sv
    WHERE month < '2026-10-01'
    GROUP BY month
)

SELECT
    gl.month,
    gl.gl_revenue,
    sv.sv_revenue,
    gl.gl_revenue - sv.sv_revenue AS difference
FROM gl
LEFT JOIN sv
    ON gl.month = sv.month
WHERE gl.gl_revenue IS DISTINCT FROM sv.sv_revenue;