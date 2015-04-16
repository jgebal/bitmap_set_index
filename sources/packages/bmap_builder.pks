ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE bmap_builder AUTHID CURRENT_USER AS


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

--bitmap parameters
  C_BITMAP_HEIGHT    CONSTANT BINARY_INTEGER := &&BITMAP_HEIGHT__DEF_VAL_IS_3;
  C_SEGMENT_CAPACITY CONSTANT BINARY_INTEGER := bmap_segment_builder.C_SEGMENT_CAPACITY;
  C_MAX_BITMAP_SIZE  CONSTANT INTEGER        := POWER( C_SEGMENT_CAPACITY, C_BITMAP_HEIGHT );

  TYPE BIN_INT_ARRAY         IS TABLE OF BINARY_INTEGER INDEX BY BINARY_INTEGER;
  TYPE BIN_INT_MATRIX        IS TABLE OF bmap_segment_builder.BIN_INT_LIST;

  PROCEDURE build_bitmaps(
    p_bit_list_crsr SYS_REFCURSOR,
    p_stor_table_name VARCHAR2
  );

END bmap_builder;
/

SHOW ERRORS
/
