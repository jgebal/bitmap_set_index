SET SERVEROUPTUT ON;
SET TIMING ON;

DECLARE
  a              SIMPLE_INTEGER := 0;
  bit_map        bmap_segment_builder.BMAP_SEGMENT;
  result         bmap_segment_builder.BMAP_SEGMENT;
  storage_bitmap STOR_BMAP_SEGMENT;
  int_lst        bmap_segment_builder.BIN_INT_LIST;
  t              NUMBER;
  loops          SIMPLE_INTEGER := 1;
  bmap_density   NUMBER := 1;
  BITS           INTEGER := 5000000;
  x              INTEGER;
  PROCEDURE put(txt VARCHAR2) IS
    BEGIN
      DBMS_OUTPUT.PUT_LINE( lpad('-',40,'-') );
      DBMS_OUTPUT.PUT_LINE( lpad('-',40,'-') );
      DBMS_OUTPUT.PUT_LINE(txt);
      DBMS_OUTPUT.PUT_LINE( lpad('-',40,'-') );
      DBMS_OUTPUT.PUT_LINE( lpad('-',40,'-') );
    END;
BEGIN

  put('
  Running with parameters:
          loops = '||loops||'
   bmap_density = '||bmap_density||'
           BITS = '||BITS);

  SELECT column_value BULK COLLECT INTO int_lst FROM TABLE( bmap_list_generator(bits, bmap_density) );


  put('encode_bmap_segment');
  mystats_pkg.ms_start;
  FOR i IN 1 .. loops LOOP
    bit_map := bmap_segment_builder.encode_bmap_segment( int_lst );
  END LOOP;
  mystats_pkg.ms_stop(10);

  put('decode_bmap_segment');
  mystats_pkg.ms_start;
  FOR i IN 1 .. loops LOOP
    int_lst := bmap_segment_builder.decode_bmap_segment( bit_map );
  END LOOP;
  mystats_pkg.ms_stop(10);

  put('segment_bit_and');
  mystats_pkg.ms_start;
  FOR i IN 1 .. loops LOOP
    result := bmap_segment_builder.segment_bit_and( bit_map, bit_map );
  END LOOP;
  mystats_pkg.ms_stop(10);

  put('segment_bit_or');
  mystats_pkg.ms_start;
  FOR i IN 1 .. loops LOOP
    result := bmap_segment_builder.segment_bit_or( bit_map, bit_map );
  END LOOP;
  mystats_pkg.ms_stop(10);

  put('segment_bit_minus');
  mystats_pkg.ms_start;
  FOR i IN 1 .. loops LOOP
    result := bmap_segment_builder.segment_bit_minus( bit_map, bit_map );
  END LOOP;
  mystats_pkg.ms_stop(10);

  put('convert_for_storage');
  mystats_pkg.ms_start;
  FOR i IN 1 .. loops LOOP
    storage_bitmap := bmap_segment_builder.convert_for_storage(bit_map);
  END LOOP;
  mystats_pkg.ms_stop(10);

  put('convert_for_processing');
  mystats_pkg.ms_start;
  FOR i IN 1 .. loops LOOP
    bit_map := bmap_segment_builder.convert_for_processing(storage_bitmap);
  END LOOP;
  mystats_pkg.ms_stop(10);

END;
/
