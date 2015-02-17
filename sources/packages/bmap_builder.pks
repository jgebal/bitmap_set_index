ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE bmap_builder AS

  --segment parameters
  C_ELEMENT_CAPACITY CONSTANT BINARY_INTEGER := 30;
  C_SEGMENT_HEIGHT   CONSTANT BINARY_INTEGER := 3;
  C_SEGMENT_CAPACITY CONSTANT BINARY_INTEGER := POWER( C_ELEMENT_CAPACITY, C_SEGMENT_HEIGHT );

--bitmap parameters
  C_BITMAP_HEIGHT    CONSTANT BINARY_INTEGER := 3;
  C_MAX_BITMAP_SIZE  CONSTANT INTEGER        := POWER( C_SEGMENT_CAPACITY, C_BITMAP_HEIGHT );

  TYPE BIN_INT_LIST          IS TABLE OF BINARY_INTEGER;
  TYPE BIN_INT_MATRIX        IS TABLE OF BIN_INT_LIST;
  TYPE BIN_INT_AARRAY        IS TABLE OF BINARY_INTEGER INDEX BY BINARY_INTEGER;
  SUBTYPE BMAP_SEGMENT_LEVEL IS BIN_INT_AARRAY;
  TYPE BMAP_SEGMENT          IS TABLE OF BMAP_SEGMENT_LEVEL INDEX BY BINARY_INTEGER;

  CURSOR BIT_LIST_C   IS (SELECT CAST(NULL AS INTEGER) bit_no, cast(NULL AS INTEGER) bit_segment_no FROM dual WHERE 1=0);
  TYPE BIT_LIST_REF_C IS REF CURSOR RETURN BIT_LIST_C%ROWTYPE;

  --bmap operators

  PROCEDURE build_bitmap_nopipe(
    p_bit_list_crsr SYS_REFCURSOR,
    p_bitmap_key INTEGER
  );

  PROCEDURE build_bitmap(
    p_bit_list_crsr  BIT_LIST_REF_C,
    p_bitmap_key     INTEGER
  );

  FUNCTION build_and_store_bmap_segments(
    p_bit_list_crsr BIT_LIST_REF_C,
    p_bitmap_key       INTEGER,
    p_segment_V_pos    INTEGER := 1
  ) RETURN INT_LIST PIPELINED
    PARALLEL_ENABLE(PARTITION p_bit_list_crsr BY HASH (bit_segment_no))
    CLUSTER p_bit_list_crsr BY (bit_segment_no)
  ;

  --segment operators
  FUNCTION encode_bmap_segment(
    p_bit_numbers_list BIN_INT_LIST
  ) RETURN BMAP_SEGMENT;

  FUNCTION decode_bmap_segment(
    p_bitmap_tree BMAP_SEGMENT
  ) RETURN BIN_INT_LIST;

  FUNCTION segment_bit_and(
    p_bmap_left  BMAP_SEGMENT,
    p_bmap_right BMAP_SEGMENT
  ) RETURN BMAP_SEGMENT;

  FUNCTION segment_bit_or(
    p_bmap_left  BMAP_SEGMENT,
    p_bmap_right BMAP_SEGMENT
  ) RETURN BMAP_SEGMENT;

  FUNCTION segment_bit_minus(
    p_bmap_left  BMAP_SEGMENT,
    p_bmap_right BMAP_SEGMENT
  ) RETURN BMAP_SEGMENT;

  PROCEDURE set_bits_in_bmap_segment(
    p_bit_numbers_list BIN_INT_LIST,
    p_bit_map_tree     IN OUT NOCOPY BMAP_SEGMENT
  );

  FUNCTION convert_for_storage(
    p_bitmap_list BMAP_SEGMENT
  ) RETURN STOR_BMAP_SEGMENT;

  FUNCTION convert_for_processing(
    p_bitmap_list STOR_BMAP_SEGMENT
  ) RETURN BMAP_SEGMENT;

END bmap_builder;
/

SHOW ERRORS
/
