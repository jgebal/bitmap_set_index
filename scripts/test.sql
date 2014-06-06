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
connect by level < 1000);

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
--  where bit_no >=99;

SET SERVEROUTPUT ON
BEGIN DBMS_OUTPUT.PUT_LINE( UTL_RAW.CAST_FROM_BINARY_INTEGER(POWER(2,0) )); end;
/

BEGIN DBMS_OUTPUT.PUT_LINE( UTL_RAW.CAST_FROM_BINARY_INTEGER(POWER(2,30) )); END;
/

BEGIN
  DBMS_OUTPUT.PUT_LINE(
      UTL_RAW.CAST_FROM_BINARY_INTEGER(
          power(-2,31)+power(2,30)
    +power(2,29)+power(2,28)+power(2,27)+power(2,26)+power(2,25)+power(2,24)+power(2,23)+power(2,22)+power(2,21)+power(2,20)
    +power(2,19)+power(2,18)+power(2,17)+power(2,16)+power(2,15)+power(2,14)+power(2,13)+power(2,12)+power(2,11)+power(2,10)
    + power(2,9)+ power(2,8)+ power(2,7)+ power(2,6)+ power(2,5)+ power(2,4)+ power(2,3)+power(2,2) +power(2,1) +power(2,0)
  ));
END;
/



