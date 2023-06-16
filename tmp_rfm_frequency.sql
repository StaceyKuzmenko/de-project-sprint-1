--заполнение таблицы tmp_rfm_frequency
INSERT INTO analysis.tmp_rfm_frequency (user_id, frequency)
SELECT  au.id AS user_id,
		NTILE(5) OVER (ORDER BY orders_data.count_orders ASC NULLS FIRST) AS frequency
FROM (
  	SELECT DISTINCT ao.user_id AS user_id,
    	   COUNT(ao.order_id) AS count_orders
	FROM analysis.orders ao
  	WHERE ao.status = 4
	GROUP BY ao.user_id
) AS orders_data
RIGHT JOIN analysis.users au ON orders_data.user_id=au.id
GROUP BY au.id, orders_data.count_orders
ORDER BY frequency ASC;