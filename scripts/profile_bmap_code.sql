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
  bmap_density NUMBER := 1;
  BITS         INTEGER := 50000;
  x            INTEGER;
BEGIN

  DBMS_OUTPUT.PUT_LINE('Running with parameters:');
  DBMS_OUTPUT.PUT_LINE('        loops = '||loops);
  DBMS_OUTPUT.PUT_LINE(' bmap_density = '||bmap_density);
  DBMS_OUTPUT.PUT_LINE('         BITS = '||BITS);

  DBMS_PROFILER.START_PROFILER(
      'build bit list ' || to_char( systimestamp, 'YYYY-MM-DD HH24:MI:SSXFF' ) );
  SELECT column_value BULK COLLECT INTO int_lst FROM TABLE( bmap_list_generator(bits, bmap_density) );
  DBMS_PROFILER.STOP_PROFILER;

  DBMS_PROFILER.START_PROFILER(
      'bmap_builder.encode_bmap_segment ' || to_char( systimestamp, 'YYYY-MM-DD HH24:MI:SSXFF' ) );
  t := DBMS_UTILITY.get_time;
  FOR i IN 1 .. loops LOOP
    bit_map := bmap_builder.encode_bmap_segment( int_lst );
  END LOOP;
  DBMS_PROFILER.STOP_PROFILER;

  DBMS_PROFILER.START_PROFILER(
      'bmap_builder.decode_bmap_segment ' || to_char( systimestamp, 'YYYY-MM-DD HH24:MI:SSXFF' ) );
  t := DBMS_UTILITY.get_time;
  FOR i IN 1 .. loops LOOP
    int_lst := bmap_builder.decode_bmap_segment( bit_map );
  END LOOP;
  DBMS_PROFILER.STOP_PROFILER;

  DBMS_PROFILER.START_PROFILER(
      'bmap_builder.segment_bit_and ' || to_char( systimestamp, 'YYYY-MM-DD HH24:MI:SSXFF' ) );
  t := DBMS_UTILITY.get_time;
  FOR i IN 1 .. loops LOOP
    result := bmap_builder.segment_bit_and( bit_map, bit_map );
  END LOOP;
  DBMS_PROFILER.STOP_PROFILER;

  DBMS_PROFILER.START_PROFILER(
      'bmap_builder.segment_bit_or ' || to_char( systimestamp, 'YYYY-MM-DD HH24:MI:SSXFF' ) );
  t := DBMS_UTILITY.get_time;
  FOR i IN 1 .. loops LOOP
    result := bmap_builder.segment_bit_or( bit_map, bit_map );
  END LOOP;
  DBMS_PROFILER.STOP_PROFILER;

  DBMS_PROFILER.START_PROFILER(
      'bmap_builder.segment_bit_minus ' || to_char( systimestamp, 'YYYY-MM-DD HH24:MI:SSXFF' ) );
  t := DBMS_UTILITY.get_time;
  FOR i IN 1 .. loops LOOP
    result := bmap_builder.segment_bit_minus( bit_map, bit_map );
  END LOOP;
  DBMS_PROFILER.STOP_PROFILER;

  DBMS_PROFILER.START_PROFILER(
      'bmap_builder.convert_for_storage ' || to_char( systimestamp, 'YYYY-MM-DD HH24:MI:SSXFF' ) );
  storage_bitmap := bmap_builder.convert_for_storage(bit_map);
  DBMS_PROFILER.STOP_PROFILER;

  DBMS_PROFILER.START_PROFILER(
      'bmap_builder.convert_for_processing ' || to_char( systimestamp, 'YYYY-MM-DD HH24:MI:SSXFF' ) );
  bit_map := bmap_builder.convert_for_processing(storage_bitmap);
  DBMS_PROFILER.STOP_PROFILER;

END;
/

