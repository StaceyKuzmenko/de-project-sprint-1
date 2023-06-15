--заполнение таблицы tmp_rfm_frequency
INSERT INTO analysis.tmp_rfm_frequency (user_id, frequency)
SELECT final_data.user_id AS user_id,
	   final_data.frequency_rank AS frequency
FROM (
    SELECT
        user_order_ranks.u_id AS user_id,
        NTILE(5) OVER (ORDER BY user_order_ranks.order_cnt_rnk) AS frequency_rank
    FROM (
        SELECT
            DISTINCT analysis.orders.user_id AS u_id, 
            COUNT(analysis.orders.order_id) AS order_quantity,
	  		ROW_NUMBER() OVER (ORDER BY COUNT(analysis.orders.order_id) ASC) AS order_cnt_rnk
        FROM 
            analysis.orders
        WHERE EXTRACT(YEAR FROM analysis.orders.order_ts) >= 2022
	  	AND analysis.orders.status = 4
	    GROUP BY analysis.orders.user_id 
	  	ORDER BY order_quantity ASC
    ) AS user_order_ranks) AS final_data
	ORDER BY frequency ASC;