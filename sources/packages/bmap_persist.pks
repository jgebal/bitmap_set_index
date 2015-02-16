ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE bmap_persist AS

  SUBTYPE BMAP_SEGMENT IS BMAP_BUILDER.BMAP_SEGMENT;

  PROCEDURE insertBitmapSegment(
    p_bitmap_key    INTEGER,
    p_segment_V_pos INTEGER,
    p_segment_H_pos INTEGER,
    p_segment STOR_BMAP_SEGMENT
  );

  FUNCTION insertBitmapLst(
    p_bitmap_list BMAP_SEGMENT
  ) RETURN INTEGER;

  FUNCTION getBitmapLst(
    p_bitmap_key INTEGER
  ) RETURN BMAP_SEGMENT;

  FUNCTION updateBitmapLst(
    p_bitmap_key  INTEGER,
    p_bitmap_list BMAP_SEGMENT
  ) RETURN INTEGER;

  FUNCTION deleteBitmapLst(
    p_bitmap_key INTEGER
  ) RETURN INTEGER;

  FUNCTION setBitmapLst(
    p_bitmap_key IN OUT INTEGER,
    p_bitmap_list BMAP_SEGMENT
  ) RETURN INTEGER;

END bmap_persist;
/

SHOW ERRORS
/
