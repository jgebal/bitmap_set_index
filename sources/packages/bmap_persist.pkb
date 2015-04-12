ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE BODY bmap_persist AS

  PROCEDURE insertBitmapSegment(
    p_stor_table_name VARCHAR2,
    p_bitmap_key    INTEGER,
    p_segment_V_pos INTEGER,
    p_segment_H_pos INTEGER,
    p_segment       STOR_BMAP_SEGMENT
  ) IS
    v_bmap_anydata ANYDATA;
  BEGIN
    v_bmap_anydata := anydata.ConvertCollection(  p_segment );
    EXECUTE IMMEDIATE
     'INSERT
        INTO '||p_stor_table_name||'
             ( BITMAP_KEY, BMAP_H_POS, BMAP_V_POS, BMAP )
      VALUES ( :p_bitmap_key, :p_segment_H_pos, :p_segment_V_pos, :v_bmap_anydata )'
    USING p_bitmap_key, p_segment_H_pos, p_segment_V_pos, v_bmap_anydata;
  END insertBitmapSegment;

END bmap_persist;
/

SHOW ERRORS
/
