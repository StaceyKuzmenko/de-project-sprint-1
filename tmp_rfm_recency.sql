--заполнение таблицы tmp_rfm_recency
INSERT INTO analysis.tmp_rfm_recency (user_id, recency)
SELECT au.id AS user_id,
	   NTILE(5) OVER (ORDER BY orders_data.last_date ASC NULLS FIRST) AS recency
FROM (
  	SELECT DISTINCT ao.user_id AS user_id,
    	   MAX(ao.order_ts) AS last_date
	FROM analysis.orders ao
  	WHERE ao.status = 4
	GROUP BY ao.user_id
) AS orders_data
RIGHT JOIN analysis.users au ON orders_data.user_id=au.id
GROUP BY au.id, orders_data.last_date
ORDER BY recency ASC;