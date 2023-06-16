--заполнение таблицы tmp_rfm_monetary_value
INSERT INTO analysis.tmp_rfm_monetary_value (user_id, monetary_value)
SELECT au.id AS user_id,
	   NTILE(5) OVER (ORDER BY SUM(orders_data.order_sum) ASC NULLS FIRST) AS monetary_value
FROM (
  	SELECT DISTINCT ao.user_id AS user_id,
    	   SUM(ao.cost) AS order_sum
	FROM analysis.orders ao
  	WHERE ao.status = 4
	GROUP BY ao.user_id
) AS orders_data
RIGHT JOIN analysis.users au ON orders_data.user_id=au.id
GROUP BY au.id, orders_data.order_sum
ORDER BY monetary_value ASC;