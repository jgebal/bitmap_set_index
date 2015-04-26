--------------------------------------------------------
--  DDL for Table EMPLOYEES
--------------------------------------------------------

BEGIN EXECUTE IMMEDIATE 'DROP TABLE employees_likes'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

CREATE TABLE employees_likes
(	employee_id NUMBER(6,0),
   like_id NUMBER(10,0)
) ;

BEGIN
  FOR x IN (SELECT employee_id FROM employees) LOOP
    INSERT INTO employees_likes
    ( employee_id, like_id )
      WITH random_dataset (row_num,row_value, rows_to_generate) as
      ( SELECT 1 AS row_num,
               trunc(abs(dbms_random.NORMAL) * &NUMBER_OF_LIKES) row_value,
               trunc( dbms_random.VALUE( 1, &NUMBER_OF_LIKES/&MIN_NUMBER_OF_LIKES_FOR_EMP ) * &MIN_NUMBER_OF_LIKES_FOR_EMP ) rows_to_generate
          FROM dual
        UNION ALL
        SELECT row_num+1 AS row_num,
               TRUNC(dbms_random.VALUE( 1, &NUMBER_OF_LIKES)) row_value,
               rows_to_generate
          FROM random_dataset
         WHERE row_num <= rows_to_generate
      )
      SELECT DISTINCT x.employee_id, row_value FROM random_dataset
    ;
    COMMIT;
  END LOOP;

END;
/

CREATE UNIQUE INDEX employees_likes_pk ON employees_likes (employee_id, like_id)
;

ALTER TABLE employees_likes ADD CONSTRAINT employees_likes_pk PRIMARY KEY (employee_id,like_id) ENABLE;

