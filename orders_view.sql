--Обновление статусов в представлении orders (из production.orderstatuslog)
CREATE OR REPLACE VIEW analysis.orders AS 
SELECT 	DISTINCT po.order_id,
		po.order_ts,
		po.user_id,
		po.bonus_payment,
		po.payment,
		po."cost",
		po.bonus_grant,
		MAX(inc.status) AS status
FROM (
  	SELECT DISTINCT order_id,
	  		 ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY dttm ASC) AS last_date,
	  		 MAX(status_id) AS status
	FROM production.orderstatuslog posl
  	GROUP BY order_id, status_id, dttm
) AS inc
RIGHT JOIN production.orders po ON inc.order_id=po.order_id
GROUP BY po.order_id; 