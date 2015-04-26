DEF BITMAP_HEIGHT__DEF_VAL_IS_3=3;
DEF SEGMENT_HEIGHT__DEF_VAL_IS_3=3;
--THE SEGMENT ELEMENTS must be greater than or eaqual to the (C_ELEMENT_CAPACITY ^ C_SEGMENT_HEIGHT - 1)
DEF SEGMENT_ELEMS__DEF_VAL_IS_900=900;

ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

@@../sources/types/int_list.tps
@@../sources/types/varchar2_lst.tps
@@../sources/types/stor_bmap_node.tps
@@../sources/types/stor_bmap_level.tps
@@../sources/types/stor_bmap_segment.tps

@@../sources/packages/bmap_segment_builder.pks
@@../sources/packages/bmap_builder.pks
@@../sources/packages/bmap_persist.pks
@@../sources/packages/bmap_maint.pks
@@../sources/packages/bmap_oper.pks

@@../sources/packages/bmap_segment_builder.pkb
@@../sources/packages/bmap_builder.pkb
@@../sources/packages/bmap_persist.pkb
@@../sources/packages/bmap_maint.pkb
@@../sources/packages/bmap_oper.pkb

EXIT