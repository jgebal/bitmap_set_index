ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE bmap_persist AS

  SUBTYPE BMAP_LEVEL_LIST IS BMAP_BUILDER.BMAP_LEVEL_LIST;

  FUNCTION convertForStorage(
    pt_bitmap_list BMAP_LEVEL_LIST
  ) RETURN STORAGE_BMAP_LEVEL_LIST;

  FUNCTION convertForProcessing(
    pt_bitmap_list STORAGE_BMAP_LEVEL_LIST
  ) RETURN BMAP_LEVEL_LIST;

  FUNCTION insertBitmapLst(
    pt_bitmap_list BMAP_LEVEL_LIST
  ) RETURN INTEGER;

  FUNCTION getBitmapLst(
    pi_bitmap_key INTEGER )
    RETURN BMAP_LEVEL_LIST;

  FUNCTION updateBitmapLst(
    pi_bitmap_key  INTEGER,
    pt_bitmap_list BMAP_LEVEL_LIST
  ) RETURN INTEGER;

  FUNCTION deleteBitmapLst(
    pi_bitmap_key INTEGER
  ) RETURN INTEGER;

  PROCEDURE setBitmapLst(
    pi_bitmap_key     IN OUT INTEGER,
    pt_bitmap_list           BMAP_LEVEL_LIST,
    pio_affected_rows OUT    INTEGER
  );

END bmap_persist;
/

SHOW ERRORS
/
