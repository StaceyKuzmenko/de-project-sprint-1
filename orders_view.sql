--Обновление статусов в представлении orders (из production.orderstatuslog)
UPDATE analysis.orders AS target_data
SET
    status = inc.status_id
FROM (SELECT DISTINCT order_id,
	  		 MAX(dttm) AS last_date,
	  		 status_id
FROM production.orderstatuslog
	 GROUP BY order_id, status_id) AS inc
WHERE
    inc.order_id = target_data.order_id
    AND inc.last_date <> target_data.order_ts;