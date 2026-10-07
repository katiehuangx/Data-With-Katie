SELECT SUM(g.amount) AS unassigned_opex
FROM gl_actuals_clean AS g
JOIN accounts AS a ON a.account_id = g.account_id
WHERE a.account_type = 'Opex'
  AND g.department_id IS NULL;