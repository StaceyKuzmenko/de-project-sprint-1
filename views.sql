DROP VIEW IF EXISTS analysis.orderitems;
DROP VIEW IF EXISTS analysis.orders;
DROP VIEW IF EXISTS analysis.orderstatuses;
DROP VIEW IF EXISTS analysis.products;
DROP VIEW IF EXISTS analysis.users;

CREATE VIEW analysis.orderitems AS SELECT * FROM production.orderitems;
CREATE VIEW analysis.orders AS SELECT * FROM production.orders;
CREATE VIEW analysis.orderstatuses AS SELECT * FROM production.orderstatuses;
CREATE VIEW analysis.products AS SELECT * FROM production.products;
CREATE VIEW analysis.users AS SELECT * FROM production.users;