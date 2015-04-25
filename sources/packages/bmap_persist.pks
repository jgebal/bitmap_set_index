ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE bmap_persist AUTHID CURRENT_USER AS

  FUNCTION get_segment_pairs_cursor(
    p_stor_table_name  VARCHAR2,
    p_left_bitmap_key  NUMBER,
    p_right_bitmap_key NUMBER,
    p_segment_H_pos_lst bmap_segment_builder.BIN_INT_LIST,
    p_segment_V_pos    INTEGER
  ) RETURN SYS_REFCURSOR;

  FUNCTION get_segment(
    p_stor_table_name  VARCHAR2,
    p_bitmap_key       NUMBER,
    p_segment_H_pos    INTEGER,
    p_segment_V_pos    INTEGER
  ) RETURN STOR_BMAP_SEGMENT;

  PROCEDURE insert_segment(
    p_stor_table_name VARCHAR2,
    p_bitmap_key    INTEGER,
    p_segment_V_pos INTEGER,
    p_segment_H_pos INTEGER,
    p_segment STOR_BMAP_SEGMENT
  );

END bmap_persist;
/

SHOW ERRORS
/
