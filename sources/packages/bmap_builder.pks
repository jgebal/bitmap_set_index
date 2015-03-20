ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE bmap_builder AS


  /**
   * Definitions:
   * Bitmap index is to be used for indexing data sets sharing common key
   * you can imagine a use case, where you want to efficiently answer a question for data set similarity like:
   * show me all people who like the same books that Mike likes
   *
   * The indexed elements will be in this case books
   * for each person, a separate set-based bitmap index will be created
   *
   * The set-based bitmap index is a two-layer hierarchical structure
   * The bitmap hierarchy consists of a pyramid in a form:
   *       *     --a root segment of bitmap
   *      ***    --list of root-child/leaf-parent segments
   *    *******  --list of leaf-child segments
   *
   * Each segment is identified by:
   * - the bitmap key (that would be person key in our example)
   * - the vertical position in hierarchy (root/child-parent/leaf-child)
   * - the horizontal position in hierarchy
   *
   * Each segment contains another level of hierarchy (nested one)
   * The nested hierarchy is similar, though it has a different structure.
   *
   * Each segment is considered an atomic unit of work.
   * When creating/manipulating/reading bitmap the bitmap is processed segment by segment
   * It was designed like that to have the solution scalable, as processing large bitmaps as a whole
   * is inefficient and could cause out of memory issues.
   *
   * A bitmap segment contains:
   * The bitmap segment hierarchy consists of a pyramid in a form:
   *       *     --a root element of bitmap segment
   *      ***    --list of root-child/leaf-parent elements of bitmap segment
   *    *******  --list of leaf-child elements of bitmap segment
   * A segment is implemented as a list of index-by lists of elements
   * An element is a BINARY_INTEGER value that represents a bitmap.

   */
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

  PROCEDURE build_bitmap(
    p_bit_list_crsr SYS_REFCURSOR,
    p_bitmap_key INTEGER
  );

  --segment operators
  PROCEDURE encode_bmap_segment(
    p_bit_no_list  BIN_INT_LIST,
    p_bmap_segment IN OUT NOCOPY BMAP_SEGMENT
  );

  FUNCTION encode_bmap_segment(
    p_bit_no_list BIN_INT_LIST
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
