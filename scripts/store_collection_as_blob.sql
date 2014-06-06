CREATE TABLE hierarchical_bitmap_table(bitmap_key integer, bmap anydata);

-- CREATE TABLE anydata_table(a integer, bmap anydata)
-- LOB (bmap) STORE AS SECUREFILE (
-- ENABLE       STORAGE IN ROW
-- );

DECLARE
  b            BMAP_LEVEL_LIST;
  int_lst      INT_LIST;
  t            NUMBER;
  loops        SIMPLE_INTEGER := 1;
  BMAP_DENSITY NUMBER := 1/2;
  BITS INTEGER := 250000;
  c anydata;
  is_ok SIMPLE_INTEGER := -1;
BEGIN
  SELECT CAST(COLLECT(ROWNUM/BMAP_DENSITY) AS int_list) INTO INT_LST FROM DUAL CONNECT BY LEVEL <= BITS*BMAP_DENSITY;

  DBMS_PROFILER.start_profiler('K_BMAP_NEW.bit_no_lst_to_bit_map '||to_char(systimestamp, 'YYYY-MM-DD HH24:MI:SSXFF'));
  t := DBMS_UTILITY.get_time;
  b := BMAP_UTIL.bit_no_lst_to_bit_map(INT_LST);

  DBMS_OUTPUT.PUT_LINE('hsecs: '||(DBMS_UTILITY.get_time - t));

  DBMS_PROFILER.stop_profiler;
  t := DBMS_UTILITY.get_time;
  FORALL i IN 1 .. 1000
INSERT INTO anydata_table
  VALUES (INT_LST(i), anydata.ConvertCollection(b));
  DBMS_OUTPUT.PUT_LINE('hsecs: '||(DBMS_UTILITY.get_time - t));
  DBMS_PROFILER.stop_profiler;
  t := DBMS_UTILITY.get_time;
  select bmap
  into c
  from anydata_table
  where rownum = 1;
  DBMS_OUTPUT.PUT_LINE('hsecs: '||(DBMS_UTILITY.get_time - t));

  t := DBMS_UTILITY.get_time;
  is_ok := anydata.getCollection(c,b);
  DBMS_OUTPUT.PUT_LINE('hsecs: '||(DBMS_UTILITY.get_time - t));
END;
/

SELECT COUNT(1)
FROM anydata_table;

SELECT a, anydata.getTypeName(bmap)
FROM anydata_table WHERE ROWNUM = 1;

SELECT * FROM DBA_SEGMENTS WHERE OWNER = USER;
SELECT SUM(BYTES)/1024/1000 KBYTES_PER_ROW, SUM(BYTES)/1024/1024 SIZE_MBYTES, SEGMENT_TYPE, SEGMENT_NAME
FROM DBA_EXTENTS
WHERE OWNER = USER
      AND SEGMENT_TYPE LIKE 'LOB%'
GROUP BY SEGMENT_TYPE, SEGMENT_NAME;


DROP TABLE anydata_table;

