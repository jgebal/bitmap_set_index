CREATE OR REPLACE PACKAGE bmap_oper AUTHID CURRENT_USER AS

  --RETURN NUMBER OF ROWS THAT ARE COMMON FOR BOTH
  FUNCTION bit_and(
    p_stor_table_name  VARCHAR2,
    p_left_bitmap_key  NUMBER,
    p_right_bitmap_key NUMBER
  ) RETURN INTEGER;

END bmap_oper;
/

SHOW ERRORS
/
