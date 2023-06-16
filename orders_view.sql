--Обновление статусов в представлении orders (из production.orderstatuslog)
CREATE OR REPLACE VIEW analysis.orders AS 
SELECT 	po.order_id,
		po.order_ts,
		po.user_id,
		po.bonus_payment,
		po.payment,
		po."cost",
		po.bonus_grant,
		inc.status
FROM (
  	SELECT DISTINCT order_id,
	  		 MAX(dttm) AS last_date,
	  		 status_id AS status
	FROM production.orderstatuslog posl
  	GROUP BY order_id, status_id
) AS inc
RIGHT JOIN production.orders po ON inc.order_id=po.order_id; 