DROP TABLE employees_likes;
--------------------------------------------------------
--  DDL for Table EMPLOYEES
--------------------------------------------------------

CREATE TABLE employees_likes
(	employee_id NUMBER(6,0),
   like_id NUMBER(10,0)
) ;

CREATE UNIQUE INDEX employees_likes_pk ON employees_likes (employee_id, like_id)
;

ALTER TABLE employees_likes ADD CONSTRAINT employees_likes_pk PRIMARY KEY (employee_id,like_id) ENABLE;

INSERT INTO employees_likes
  SELECT employee_id, like_id
  FROM employees
    CROSS JOIN likes
  WHERE like_id BETWEEN dbms_random.VALUE(mod(employee_id,1)+1,50) AND dbms_random.VALUE(mod(employee_id,1)+7500,10000);

COMMIT;