--заполнение таблицы dm_rfm_segments
INSERT INTO analysis.dm_rfm_segments (user_id, recency, frequency, monetary_value)
SELECT DISTINCT o.user_id AS user_id,
	   trr.recency AS recency,
	   trf.frequency AS frequency,
	   trmv.monetary_value AS monetary_value
FROM analysis.orders o
LEFT JOIN tmp_rfm_recency trr ON o.user_id = trr.user_id
LEFT JOIN tmp_rfm_frequency trf ON o.user_id = trf.user_id	
LEFT JOIN tmp_rfm_monetary_value trmv ON o.user_id = trmv.user_id
ORDER BY user_id
LIMIT 10;