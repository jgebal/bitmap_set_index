SET SERVEROUPTUT ON;
SET TIMING ON;

DECLARE
  a SIMPLE_INTEGER :=0;
  b BMAP_LEVEL_LIST;
  INT_LST int_list;
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
    b := BMAP_UTIL.bit_no_lst_to_bit_map(INT_LST);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('hsecs: '||(DBMS_UTILITY.get_time - t));
  DBMS_PROFILER.stop_profiler;

END;
/

