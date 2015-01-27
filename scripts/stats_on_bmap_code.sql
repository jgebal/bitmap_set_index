SET SERVEROUPTUT ON;
SET TIMING ON;

DECLARE
  a            SIMPLE_INTEGER := 0;
  bit_map      bmap_builder.BMAP_SEGMENT;
  result       bmap_builder.BMAP_SEGMENT;
  storage_bitmap STORAGE_BMAP_LEVEL_LIST;
  int_lst      INT_LIST;
  t            NUMBER;
  loops        SIMPLE_INTEGER := 1;
  bmap_density NUMBER := 1 / 2;
  BITS         INTEGER := 1000000;
  x            INTEGER;
BEGIN

  DBMS_OUTPUT.PUT_LINE('Running with parameters:');
  DBMS_OUTPUT.PUT_LINE('        loops = '||loops);
  DBMS_OUTPUT.PUT_LINE(' bmap_density = '||bmap_density);
  DBMS_OUTPUT.PUT_LINE('         BITS = '||BITS);

  mystats_pkg.ms_start;
  SELECT column_value BULK COLLECT INTO int_lst FROM TABLE( bmap_list_generator(bits, bmap_density) );
  mystats_pkg.ms_stop(10);

  mystats_pkg.ms_start;
  FOR i IN 1 .. loops LOOP
    bit_map := bmap_builder.encode_bitmap( int_lst );
  END LOOP;
  mystats_pkg.ms_stop(10);

  mystats_pkg.ms_start;
  FOR i IN 1 .. loops LOOP
    int_lst := bmap_builder.decode_bitmap( bit_map );
  END LOOP;
  mystats_pkg.ms_stop(10);

  mystats_pkg.ms_start;
  FOR i IN 1 .. loops LOOP
    result := bmap_builder.bit_and( bit_map, bit_map );
  END LOOP;
  mystats_pkg.ms_stop(10);

  mystats_pkg.ms_start;
  FOR i IN 1 .. loops LOOP
    result := bmap_builder.bit_or( bit_map, bit_map );
  END LOOP;
  mystats_pkg.ms_stop(10);

  mystats_pkg.ms_start;
  FOR i IN 1 .. loops LOOP
    result := bmap_builder.bit_minus( bit_map, bit_map );
  END LOOP;
  mystats_pkg.ms_stop(10);

  mystats_pkg.ms_start;
  FOR i IN 1 .. loops LOOP
    storage_bitmap := bmap_persist.convertForStorage(bit_map);
  END LOOP;
  mystats_pkg.ms_stop(10);

  mystats_pkg.ms_start;
  FOR i IN 1 .. loops LOOP
    bit_map := bmap_persist.convertForProcessing(storage_bitmap);
  END LOOP;
  mystats_pkg.ms_stop(10);

  mystats_pkg.ms_start;
  FOR i IN 1 .. loops LOOP
    x := bmap_persist.insertBitmapLst(bit_map);
  END LOOP;
  mystats_pkg.ms_stop(10);

END;
/

DROP FUNCTION bmap_list_generator;