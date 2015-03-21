SET TIMING ON

CREATE OR REPLACE FUNCTION bmap_list_generator(p_bits INTEGER, p_density INTEGER) RETURN INT_LIST PIPELINED IS
  v_rows INTEGER := p_bits*p_density;
  i      INTEGER := 1;
  BEGIN
    LOOP
      PIPE ROW(TRUNC(i/p_density));
      EXIT WHEN i > v_rows;
      i := i + 1;
    END LOOP;
    RETURN;
  END bmap_list_generator;
/

DECLARE
  c                       SYS_REFCURSOR;
  t                       NUMBER := dbms_utility.get_time;
  C_DATASET_SIZE CONSTANT INTEGER := 40000000;
  C_OFFSET       CONSTANT INTEGER := 100000000000;
BEGIN
  OPEN c FOR SELECT COLUMN_VALUE + C_OFFSET bit_no FROM TABLE ( bmap_list_generator( C_DATASET_SIZE, 1) );
  bmap_builder.build_bitmap( c, 100 );
  CLOSE c;
  dbms_output.put_line( 'Took: ' || ( dbms_utility.get_time - t ) / 100 || ' sec, with dataset:' || C_DATASET_SIZE );
END;
/

--Took:  12,68 sec, with dataset:2000000
--Took: 100,37 sec, with dataset:20000000
--Took: 99,62 sec, with dataset:20000000
--Took: 200,59 sec, with dataset:40000000
