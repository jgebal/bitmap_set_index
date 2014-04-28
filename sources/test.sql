select * from (
SELECT rownum bit_no,
       MOD(rownum-1,31) leaf_bit_no,
       ceil((rownum)/31) leaf_no,
       ceil((rownum)/31) * 31 + 1 next_leaf_bit ,
       MOD(ceil((rownum)/31)-1,31) level_1_bit_no,
       ceil((rownum)/31/31) level_1_branch_no,
       MOD(ceil((rownum)/31/31)-1,31) level_2_bit_no,
       ceil((rownum)/31/31/31) level_2_branch_no,
       MOD(ceil((rownum)/31/31/31)-1,31) level_3_bit_no,
       ceil((rownum)/31/31/31/31) level_4_bit_no
  from dual
connect by level <1000);

select * from (
SELECT rownum bit_no,
       MOD(ceil(rownum/power(31,0))-1,31) leaf_bit_no,
           ceil(rownum/power(31,1)) leaf_no,
       MOD(ceil(rownum/power(31,1))-1,31) level_1_bit_no,
           ceil(rownum/power(31,2)) level_1_branch_no,
       MOD(ceil(rownum/power(31,2))-1,31) level_2_bit_no,
           ceil(rownum/power(31,3)) level_2_branch_no,
       MOD(ceil(rownum/power(31,3))-1,31) level_3_bit_no,
           ceil(rownum/power(31,4)) level_4_bit_no
  from dual
connect by level <1000);
 where bit_no >=99;

EXEC DBMS_OUTPUT.PUT_LINE( UTL_RAW.CAST_FROM_BINARY_INTEGER(POWER(2,0) ));
EXEC DBMS_OUTPUT.PUT_LINE( UTL_RAW.CAST_FROM_BINARY_INTEGER(POWER(2,30) ));
begin
DBMS_OUTPUT.PUT_LINE( UTL_RAW.CAST_FROM_BINARY_INTEGER(
POWER(-2,31)+power(2,30)
+power(2,29)+power(2,28)+power(2,27)+power(2,26)+power(2,25)+power(2,24)+power(2,23)+power(2,22)+power(2,21)+power(2,20)
+power(2,19)+power(2,18)+power(2,17)+power(2,16)+power(2,15)+power(2,14)+power(2,13)+power(2,12)+power(2,11)+power(2,10)
+ power(2,9)+ power(2,8)+ power(2,7)+ power(2,6)+ power(2,5)+ power(2,4)+ power(2,3)+power(2,2) +power(2,1) +power(2,0)
));
end;
/

DECLARE
  a SIMPLE_INTEGER :=0;
  b BMAP_LEVEL_LIST;
  INT_LST int_list;
  NUM_LST NUMBERLIST;
  r raw(31767);
  t NUMBER;
  loops SIMPLE_INTEGER := 1;
  BMAP_DENSITY NUMBER := 1/2;
  BITS INTEGER := 250000; 
BEGIN
  SELECT CAST(COLLECT(ROWNUM/BMAP_DENSITY) AS int_list) INTO INT_LST FROM DUAL CONNECT BY LEVEL <= BITS*BMAP_DENSITY;
  
  DBMS_PROFILER.start_profiler('K_BMAP_NEW.bit_no_lst_to_bit_map '||to_char(systimestamp, 'YYYY-MM-DD HH24:MI:SSXFF'));
  t := DBMS_UTILITY.get_time;
  FOR i IN 1 .. loops LOOP
    b := BMAP_UTL.bit_no_lst_to_bit_map(INT_LST);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('hsecs: '||(DBMS_UTILITY.get_time - t));
  DBMS_PROFILER.stop_profiler;

  DBMS_PROFILER.start_profiler('K_BMAP_NEW.bit_no_lst_to_bit_map1 '||to_char(systimestamp, 'YYYY-MM-DD HH24:MI:SSXFF'));
  t := DBMS_UTILITY.get_time;
  FOR i IN 1 .. loops LOOP
    b := BMAP_UTL.bit_no_lst_to_bit_map1(INT_LST);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('hsecs: '||(DBMS_UTILITY.get_time - t));
  DBMS_PROFILER.stop_profiler;
  
  SELECT CAST(COLLECT(ROWNUM/BMAP_DENSITY) AS numberlist) INTO NUM_LST FROM DUAL CONNECT BY LEVEL <= BITS*BMAP_DENSITY;
  DBMS_PROFILER.start_profiler('K_OBF_BMAP.bitLstToBitmap '||to_char(systimestamp, 'YYYY-MM-DD HH24:MI:SSXFF'));
  t := DBMS_UTILITY.get_time;
  FOR i IN 1 .. loops LOOP
    r := K_OBF_BMAP.bitLstToBitmap(num_lst);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('hsecs: '||(DBMS_UTILITY.get_time - t));
  DBMS_PROFILER.stop_profiler;
  COMMIT;
END;
/

--preview the perf of PLSQL code
SELECT a.runid, a.run_owner, a.run_comment,
       a.run_total_time / 1000000000 run_secs,
       c.total_occur,
       c.total_time / 1000000000 line_total_secs,
       b.unit_type, b.unit_owner, b.unit_name, c.line#, u.text
  FROM plsql_profiler_runs a
  JOIN plsql_profiler_units b ON ( a.runid = b.runid )
  JOIN plsql_profiler_data c ON ( a.runid = c.runid AND b.unit_number = c.unit_number)
  LEFT JOIN dba_source u ON (b.unit_name = u.NAME AND b.unit_owner = u.owner AND c.line# = u.line AND b.unit_type = u.TYPE )
 WHERE 1=1
 --AND b.unit_owner <> 'EMACH'
--   AND b.unit_owner in ('MD','LOG4PLSQL')
   --AND  b.unit_owner = 'MACHXJGE'
   --AND unit_name = 'BITNADSPEEDTEST'
   AND total_occur > 0
--   AND RUN_COMMENT LIKE '%NEW%'
   AND C.total_time > 10000000
 ORDER BY a.runid DESC, line_total_secs DESC, 
    unit_name, line
;

truncate table plsql_profiler_runs;
truncate table plsql_profiler_units;
truncate table plsql_profiler_data;


CREATE TABLE anydata_table(a integer, bmap anydata) LOB (BMAP) STORE AS SECUREFILE (
  TABLESPACE S_BI_APP_D
  ENABLE       STORAGE IN ROW
  INDEX       (TABLESPACE S_BI_APP_D))
TABLESPACE S_BI_APP_D;

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
  b := BMAP_UTL.bit_no_lst_to_bit_map(INT_LST);
  
  DBMS_OUTPUT.PUT_LINE('hsecs: '||(DBMS_UTILITY.get_time - t));
  
  DBMS_PROFILER.stop_profiler;
  t := DBMS_UTILITY.get_time;
  FORALL i IN 1 .. 1000
  INSERT INTO anydata_table
  VALUES (INT_LST(i), anydata.ConvertCollection(b)); 
  DBMS_OUTPUT.PUT_LINE('hsecs: '||(DBMS_UTILITY.get_time - t));
  DBMS_PROFILER.stop_profiler;

  t := DBMS_UTILITY.get_time;
  select b
    into c
    from anydata_table
    where rownum = 1;
  DBMS_OUTPUT.PUT_LINE('hsecs: '||(DBMS_UTILITY.get_time - t));
  
  t := DBMS_UTILITY.get_time;
  is_ok := anydata.getCollection(c,b);
  DBMS_OUTPUT.PUT_LINE('hsecs: '||(DBMS_UTILITY.get_time - t));
END;
/
  
SELECT a, anydata.getTypeName(b)
  FROM anydata_table;

DROP TABLE anydata_table;

SELECT SUM(BYTES)/1024/1000 KBYTES_PER_ROW FROM DBA_EXTENTS WHERE SEGMENT_NAME = 'SYS_LOB0003840494C00002$$';

SELECT * 
  FROM DBA_EXTENTS WHERE OWNER = 'MACHXJGE';
