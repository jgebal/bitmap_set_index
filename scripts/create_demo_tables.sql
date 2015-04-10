DROP TABLE customers;
DROP TABLE companies;
DROP TABLE customer_services;
DROP TABLE services;

CREATE TABLE customers (
  customer_id INTEGER NOT NULL,
  first_name VARCHAR2(60) NOT NULL,
  CONSTRAINT customers_pXk PRIMARY KEY (customer_id));

CREATE TABLE services(
  service_id INTEGER NOT NULL,
  service_NAME VARCHAR2(120) NOT NULL,
  CONSTRAINT services_pk PRIMARY KEY (service_id));

CREATE TABLE companies(
  company_id INTEGER NOT NULL,
  company_nAME VARCHAR2(120) NOT NULL,
  CONSTRAINT companies_pk PRIMARY KEY (company_id));

CREATE TABLE customer_services(
  customer_service_id INTEGER NOT NULL,
  customer_id INTEGER NOT NULL,
  service_id INTEGER NOT NULL,
  company_id INTEGER NOT NULL,
  service_month DATE NOT NULL,
  price NUMBER default 0 NOT NULL,
  CONSTRAINT customer_services_pk PRIMARY KEY (customer_service_id),
  CONSTRAINT customer_services_uk UNIQUE (customer_id, service_id, company_id, service_month)
);

INSERT INTO customers VALUES (1, 'Adam');
INSERT INTO customers VALUES (2, 'Paul');
INSERT INTO customers VALUES (3, 'Mark');
INSERT INTO customers VALUES (4, 'Dave');
INSERT INTO customers VALUES (5, 'Jack');
INSERT INTO customers VALUES (6, 'Monique');
INSERT INTO customers VALUES (7, 'Al');
INSERT INTO customers VALUES (8, 'Tom');
INSERT INTO customers
  SELECT ROWNUM + 8, DBMS_RANDOM.string('U',10)
  FROM  DUAL
  CONNECT BY LEVEL < 100;


INSERT INTO services VALUES (1,'House Cleaning');
INSERT INTO services VALUES (2,'Catering');
INSERT INTO services VALUES (3,'Furniture Reneval');
INSERT INTO services VALUES (4,'Painting');
INSERT INTO services VALUES (5,'Car Wash');
INSERT INTO services VALUES (6,'Shoppoing');
INSERT INTO services VALUES (7,'Gardening');
INSERT INTO services VALUES (8,'Dry Washing');
INSERT INTO services VALUES (9,'Daycare');
INSERT INTO services VALUES (10,'other1');
INSERT INTO services VALUES (11,'other');
INSERT INTO services VALUES (12,'other');
INSERT INTO services VALUES (13,'other');
INSERT INTO services VALUES (14,'other');
INSERT INTO services VALUES (15,'other');
INSERT INTO services VALUES (16,'other');
INSERT INTO services VALUES (17,'other');
INSERT INTO services VALUES (18,'other');
INSERT INTO services VALUES (19,'other');
INSERT INTO services VALUES (20,'other');

INSERT INTO companies VALUES (1, 'House hold inc');
INSERT INTO companies VALUES (2, 'House care inc');
INSERT INTO companies VALUES (3, 'All house care');
INSERT INTO companies VALUES (4, 'We will take best care for your houshold');
INSERT INTO companies VALUES (5, 'BestHouseKeepingEver.com');
INSERT INTO companies VALUES (6, 'Cheapest house services');
INSERT INTO companies
  SELECT ROWNUM + 6, DBMS_RANDOM.string('U',20)
  FROM  DUAL
  CONNECT BY LEVEL < 100;

commit;

INSERT INTO customer_services
  SELECT ROWNUM,
    customer_id,
    service_id,
    company_id,
    service_month,
    ROUND(DBMS_RANDOM.VALUE(1,1000),2) price
  FROM serviceS s
    CROSS JOIN companies c
    CROSS JOIN customers cu
    CROSS JOIN (select ADD_MONTHS(TRUNC(SYSDATE,'MM'),ROWNUM) service_month FROM DUAL CONNECT BY LEVEL <=12)
;


-- find customers who used the same services from the same providers on the same months as Adam did.
SELECT first_name
FROM customers
WHERE customer_id
      IN (SELECT other_s.customer_id-- count customer_services that match adams services
          FROM customer_services other_s
            JOIN customer_services adam_s
              ON (other_s.customer_id != adam_s.customer_id
                  AND other_s.service_id = adam_s.service_id
                  AND other_s.company_id = adam_s.company_id
                  AND other_s.service_month = adam_s.service_month)
            JOIN customers adam
              ON (adam.customer_id = adam_s.customer_id)
          WHERE adam.first_name = 'Adam'
          GROUP BY other_s.customer_id
          HAVING count(1)
                 = (SELECT count(1) FROM customer_services adam_s
            JOIN customers adam
              ON (adam.customer_id = adam_s.customer_id)
          WHERE adam.first_name = 'Adam'
          )
);

--SET COMPARISION IS NOT AN EASY TASK FOR SQL
http://stackoverflow.com/questions/19807987/sql-compare-two-sets


--how about if we could use one of such simple queries to obtain the list?
SELECT first_name
FROM customers other
WHERE set_equals(set_id => other.customer_id
, compared_set => CURSOR(SELECT service_id, company_id, service_month
                         FROM customer_services
                           JOIN customers adam
                             ON (adam.customer_id = adam_s.customer_id)
                         WHERE adam.first_name = 'Adam')
                  );

SELECT first_name
FROM customers other
CROSS JOIN customers adam
WHERE adam.first_name = 'Adam'
AND set_equals(set_id => other.customer_id, compared_set => adam.customer_id
              , set_table => 'customer_services', set_columns => 'service_id, company_id, service_month')
);
