SET SERVEROUPTUT ON;
SET TIMING ON;

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
  a            SIMPLE_INTEGER := 0;
  bit_map      bmap_builder.BMAP_LEVEL_LIST;
  result       bmap_builder.BMAP_LEVEL_LIST;
  storage_bitmap STORAGE_BMAP_LEVEL_LIST;
  int_lst      INT_LIST;
  t            NUMBER;
  loops        SIMPLE_INTEGER := 1;
  bmap_density NUMBER := 1/2;
  BITS         INTEGER := 1000000;
  x            INTEGER;
BEGIN

  DBMS_OUTPUT.PUT_LINE('Running with parameters:');
  DBMS_OUTPUT.PUT_LINE('        loops = '||loops);
  DBMS_OUTPUT.PUT_LINE(' bmap_density = '||bmap_density);
  DBMS_OUTPUT.PUT_LINE('         BITS = '||BITS);
  t := DBMS_UTILITY.get_time;
  SELECT column_value BULK COLLECT INTO int_lst FROM TABLE( bmap_list_generator(bits, bmap_density) );
  DBMS_OUTPUT.PUT_LINE( 'build a list of bits secs: ' || ( DBMS_UTILITY.get_time - t )/100 );

  t := DBMS_UTILITY.get_time;
  FOR i IN 1 .. loops LOOP
    bit_map := bmap_builder.encode_bitmap( int_lst );
  END LOOP;
  DBMS_OUTPUT.PUT_LINE( 'bmap_builder.encode_bitmap secs: ' || ( DBMS_UTILITY.get_time - t )/100 );

  t := DBMS_UTILITY.get_time;
  FOR i IN 1 .. loops LOOP
    int_lst := bmap_builder.decode_bitmap( bit_map );
  END LOOP;
  DBMS_OUTPUT.PUT_LINE( 'bmap_builder.decode_bitmap secs: ' || ( DBMS_UTILITY.get_time - t )/100 );

  t := DBMS_UTILITY.get_time;
  FOR i IN 1 .. loops LOOP
    result := bmap_builder.bit_and( bit_map, bit_map );
  END LOOP;
  DBMS_OUTPUT.PUT_LINE( 'bmap_builder.bit_and secs: ' || ( DBMS_UTILITY.get_time - t )/100 );

  t := DBMS_UTILITY.get_time;
  FOR i IN 1 .. loops LOOP
    result := bmap_builder.bit_or( bit_map, bit_map );
  END LOOP;
  DBMS_OUTPUT.PUT_LINE( 'bmap_builder.bit_or secs: ' || ( DBMS_UTILITY.get_time - t )/100 );

  t := DBMS_UTILITY.get_time;
  FOR i IN 1 .. loops LOOP
    result := bmap_builder.bit_minus( bit_map, bit_map );
  END LOOP;
  DBMS_OUTPUT.PUT_LINE( 'bmap_builder.bit_minus secs: ' || ( DBMS_UTILITY.get_time - t )/100 );

  t := DBMS_UTILITY.get_time;
  storage_bitmap := bmap_persist.convertForStorage(bit_map);
  DBMS_OUTPUT.PUT_LINE( 'bmap_persist.convertForStorage secs: ' || ( DBMS_UTILITY.get_time - t )/100 );

  t := DBMS_UTILITY.get_time;
  bit_map := bmap_persist.convertForProcessing(storage_bitmap);
  DBMS_OUTPUT.PUT_LINE( 'bmap_persist.convertForProcessing secs: ' || ( DBMS_UTILITY.get_time - t )/100 );

  t := DBMS_UTILITY.get_time;
  x := bmap_persist.insertBitmapLst(bit_map);
  DBMS_OUTPUT.PUT_LINE( 'bmap_persist.insertBitmapLst secs: ' || ( DBMS_UTILITY.get_time - t )/100 );

  ROLLBACK;
END;
/

DROP FUNCTION bmap_list_generator;