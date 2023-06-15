--заполнение таблицы tmp_rfm_monetary_value
INSERT INTO analysis.tmp_rfm_monetary_value (user_id, monetary_value)
SELECT final_data_2.user_id AS user_id,
	   final_data_2.monetary_rank AS monetary_value
FROM (
    SELECT
        user_order_ranks.u_id AS user_id,
  		NTILE(5) OVER (ORDER BY user_order_ranks.order_cnt_rnk) AS monetary_rank
    FROM (
        SELECT
            DISTINCT analysis.orders.user_id AS u_id,
	  		SUM(analysis.orders.cost) AS order_sum,
            ROW_NUMBER() OVER (ORDER BY SUM(analysis.orders.cost) ASC) AS order_cnt_rnk
        FROM 
            analysis.orders
        WHERE EXTRACT(YEAR FROM analysis.orders.order_ts) >= 2022
	  	AND analysis.orders.status = 4
	    GROUP BY analysis.orders.user_id
    ) AS user_order_ranks) AS final_data_2
	ORDER BY monetary_value ASC;