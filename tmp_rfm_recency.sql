--заполнение таблицы tmp_rfm_recency
INSERT INTO analysis.tmp_rfm_recency (user_id, recency)
SELECT final_data_1.user_id AS user_id,
	   final_data_1.recency_rank AS recency
FROM (
    SELECT
        user_order_ranks.u_id AS user_id,
  		NTILE(5) OVER (ORDER BY user_order_ranks.order_cnt_rnk) AS recency_rank
    FROM (
        SELECT
            DISTINCT analysis.orders.user_id AS u_id,
	  		MAX(analysis.orders.order_ts) AS last_data,
            ROW_NUMBER() OVER (ORDER BY MAX(analysis.orders.order_ts) ASC) AS order_cnt_rnk
        FROM 
            analysis.orders
        WHERE EXTRACT(YEAR FROM analysis.orders.order_ts) >= 2022
	  	AND analysis.orders.status = 4
	    GROUP BY analysis.orders.user_id
    ) AS user_order_ranks) AS final_data_1
	ORDER BY recency ASC;