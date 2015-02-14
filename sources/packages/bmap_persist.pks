ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE bmap_persist AS

  SUBTYPE BMAP_SEGMENT IS BMAP_BUILDER.BMAP_SEGMENT;

  PROCEDURE insertBitmapSegment(
    pi_bitmap_key    INTEGER,
    pi_segment_V_pos INTEGER,
    pi_segment_H_pos INTEGER,
    pi_segment STOR_BMAP_SEGMENT
  );

  FUNCTION insertBitmapLst(
    pt_bitmap_list BMAP_SEGMENT
  ) RETURN INTEGER;

  FUNCTION getBitmapLst(
    pi_bitmap_key INTEGER
  ) RETURN BMAP_SEGMENT;

  FUNCTION updateBitmapLst(
    pi_bitmap_key  INTEGER,
    pt_bitmap_list BMAP_SEGMENT
  ) RETURN INTEGER;

  FUNCTION deleteBitmapLst(
    pi_bitmap_key INTEGER
  ) RETURN INTEGER;

  FUNCTION setBitmapLst(
    pio_bitmap_key IN OUT INTEGER,
    pt_bitmap_list BMAP_SEGMENT
  ) RETURN INTEGER;

END bmap_persist;
/

SHOW ERRORS
/
