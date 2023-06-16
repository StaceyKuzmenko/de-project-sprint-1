# Витрина RFM

## 1.1. Выясните требования к целевой витрине.

Постановка задачи выглядит достаточно абстрактно - постройте витрину. Первым делом вам необходимо выяснить у заказчика детали. Запросите недостающую информацию у заказчика в чате.

Зафиксируйте выясненные требования. Составьте документацию готовящейся витрины на основе заданных вами вопросов, добавив все необходимые детали.

-----------

{Впишите сюда ваш ответ}
- Витрину необходимо расположить в базе данных "de", схеме "analysis" и назвать "dm_rfm_segments"
- Поля витрины:
user_id
recency (число от 1 до 5)
frequency (число от 1 до 5)
monetary_value (число от 1 до 5)
- Период данных: с начала 2022 года
- статус заказов, используемых в витрине - closed (в таблице orderstatuses - 4)
- витрина не обновляется

## 1.2. Изучите структуру исходных данных.

Подключитесь к базе данных и изучите структуру таблиц.

Если появились вопросы по устройству источника, задайте их в чате.

Зафиксируйте, какие поля вы будете использовать для расчета витрины.

-----------

{Впишите сюда ваш ответ}
- Для расчета витрины я буду использовать таблицу orders (в ней есть вся информация о заказах (дата - order_ts, статус - status) и user_id)



## 1.3. Проанализируйте качество данных

Изучите качество входных данных. Опишите, насколько качественные данные хранятся в источнике. Так же укажите, какие инструменты обеспечения качества данных были использованы в таблицах в схеме production.

-----------

{Впишите сюда ваш ответ}
 
- В первую очередь я изучила DDL каждой таблицы, чтобы определить, какие есть ограничения, какие поля могут быть с пропущенными значениями (Null), какие типы данных используются.


- Таблица orderitems:
- Согласно DDL во всех полях отсутствуют значения Null
- Стоят ограничения: скидка не может быть больше цены, а также больше или равна 0; order_id и product_id уникальны; id является первичным ключом; price не может быть меньше 0; quantity больше 0. Типы данных согласуются с логикой полей, в которых они используются.

- Таблица orders:
- Согласно DDL во всех полях отсутствуют значения Null
- Стоят ограничения: cost = (payment + bonus_payment); order_id является первичным ключом. Типы данных согласуются с логикой полей, в которых они используются.

- Таблица orderstatuses:
- Согласно DDL во всех полях отсутствуют значения Null
- Стоит ограничение: id является первичным ключом. Типы данных согласуются с логикой полей, в которых они используются.

- Таблица products:
- Согласно DDL во всех полях отсутствуют значения Null
- Стоят ограничения: id является первичным ключом; price не может быть меньше 0. Типы данных согласуются с логикой полей, в которых они используются.

- Таблица users:
- Согласно DDL во всех полях, кроме name, отсутствуют значения Null
- Стоят ограничения: id является первичным ключом. Типы данных согласуются с логикой полей, в которых они используются.

- Я проверила наличие дублей с помощью кода '''select distinct count(id),
count(id)''', который написала к каждой из таблиц. Оба показателя оказались равны друг другу, что означает, что в таблицах нет дублей.

## 1.4. Подготовьте витрину данных

Теперь, когда требования понятны, а исходные данные изучены, можно приступить к реализации.

### 1.4.1. Сделайте VIEW для таблиц из базы production.**

Вас просят при расчете витрины обращаться только к объектам из схемы analysis. Чтобы не дублировать данные (данные находятся в этой же базе), вы решаете сделать view. Таким образом, View будут находиться в схеме analysis и вычитывать данные из схемы production. 

Напишите SQL-запросы для создания пяти VIEW (по одному на каждую таблицу) и выполните их. Для проверки предоставьте код создания VIEW.

```SQL
--Впишите сюда ваш ответ

CREATE VIEW analysis.orderitems AS SELECT * FROM production.orderitems;
CREATE VIEW analysis.orders AS SELECT * FROM production.orders;
CREATE VIEW analysis.orderstatuses AS SELECT * FROM production.orderstatuses;
CREATE VIEW analysis.products AS SELECT * FROM production.products;
CREATE VIEW analysis.users AS SELECT * FROM production.users;


```

### 1.4.2. Напишите DDL-запрос для создания витрины.**

Далее вам необходимо создать витрину. Напишите CREATE TABLE запрос и выполните его на предоставленной базе данных в схеме analysis.

```SQL
--Впишите сюда ваш ответ
DROP TABLE IF EXISTS analysis.dm_rfm_segments;
DROP TABLE IF EXISTS analysis.tmp_rfm_recency;
DROP TABLE IF EXISTS analysis.tmp_rfm_frequency;
DROP TABLE IF EXISTS analysis.tmp_rfm_monetary_value;

CREATE TABLE analysis.dm_rfm_segments(
  user_id int4 NOT NULL PRIMARY KEY,
  recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5),
  frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5),
  monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);

CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);
CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);
CREATE TABLE analysis.tmp_rfm_monetary_value (
 user_id INT NOT NULL PRIMARY KEY,
 monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);


```

### 1.4.3. Напишите SQL запрос для заполнения витрины

Наконец, реализуйте расчет витрины на языке SQL и заполните таблицу, созданную в предыдущем пункте.

Для решения предоставьте код запроса.

```SQL
--Впишите сюда ваш ответ
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
	
--заполнение таблицы dm_rfm_segments
INSERT INTO analysis.dm_rfm_segments (user_id, recency, frequency, monetary_value)
SELECT DISTINCT trr.user_id AS user_id,
	   trr.recency AS recency,
	   trf.frequency AS frequency,
	   trmv.monetary_value AS monetary_value
FROM analysis.tmp_rfm_recency trr
LEFT JOIN analysis.tmp_rfm_frequency trf ON trr.user_id = trf.user_id	
LEFT JOIN analysis.tmp_rfm_monetary_value trmv ON trr.user_id = trmv.user_id
ORDER BY trr.user_id
LIMIT 10;



```



