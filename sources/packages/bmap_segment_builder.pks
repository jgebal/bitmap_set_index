ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE bmap_segment_builder AUTHID CURRENT_USER AS


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
  --ELEMENT CAPACITY is at maximum 30, this is because we use binary integer datatype and operating on it up to value of 2^30 is simplest
  C_ELEMENT_CAPACITY CONSTANT BINARY_INTEGER := 30;
  C_SEGMENT_HEIGHT   CONSTANT BINARY_INTEGER := 3;
  C_SEGMENT_CAPACITY CONSTANT BINARY_INTEGER := POWER( C_ELEMENT_CAPACITY, C_SEGMENT_HEIGHT );

  TYPE BIN_INT_LIST          IS TABLE OF BINARY_INTEGER;
  TYPE BMAP_SEGMENT_LEVEL    IS TABLE OF BINARY_INTEGER INDEX BY BINARY_INTEGER;
  TYPE BMAP_SEGMENT          IS TABLE OF BMAP_SEGMENT_LEVEL INDEX BY BINARY_INTEGER;

  PROCEDURE encode_bmap_segment(
    p_bit_no_list  BIN_INT_LIST,
    p_bmap_segment IN OUT NOCOPY BMAP_SEGMENT
  );

  FUNCTION encode_and_convert(
    p_bit_no_list BIN_INT_LIST
  ) RETURN STOR_BMAP_SEGMENT;

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

  PROCEDURE convert_for_storage(
    p_bitmap_list BMAP_SEGMENT,
    p_level_list  IN OUT NOCOPY STOR_BMAP_SEGMENT
  );

  FUNCTION convert_for_processing(
    p_bitmap_list STOR_BMAP_SEGMENT
  ) RETURN BMAP_SEGMENT;

  FUNCTION segment_bit_and(
    p_bmap_left  STOR_BMAP_SEGMENT,
    p_bmap_right STOR_BMAP_SEGMENT
  ) RETURN BMAP_SEGMENT;

END bmap_segment_builder;
/

SHOW ERRORS
/
