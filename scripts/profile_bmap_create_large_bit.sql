SET SERVEROUPTUT ON;
SET TIMING ON;

DECLARE
  bit_map BMAP_LEVEL_LIST;
  INT_LST int_list;
  start_time NUMBER;
  BMAP_DENSITY NUMBER := 1/2;
  BITS INTEGER := 250000;
BEGIN
  INT_LST := int_list(bmap_util.c_max_bits/2);

  DBMS_PROFILER.start_profiler('K_BMAP_NEW.bit_no_lst_to_bit_map '||to_char(systimestamp, 'YYYY-MM-DD HH24:MI:SSXFF'));
  start_time := DBMS_UTILITY.get_time;
  bit_map := BMAP_UTIL.bit_no_lst_to_bit_map(INT_LST);
  DBMS_OUTPUT.PUT_LINE('hsecs: '||(DBMS_UTILITY.get_time - start_time));
  DBMS_PROFILER.stop_profiler;

END;
/

