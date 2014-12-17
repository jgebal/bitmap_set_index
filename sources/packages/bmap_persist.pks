ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE bmap_persist AS

  C_INDEX_LENGTH CONSTANT BINARY_INTEGER := 31;
  C_INDEX_DEPTH CONSTANT BINARY_INTEGER := 5;
  C_MAX_BITS CONSTANT NUMBER := POWER( C_INDEX_LENGTH, C_INDEX_DEPTH );


  FUNCTION bit_no_lst_to_bit_map(
    pt_bit_numbers_list INT_LIST
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

  FUNCTION get_index_length RETURN INTEGER;

END bmap_persist;
/

SHOW ERRORS
/
