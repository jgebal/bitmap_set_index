ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE BODY bmap_builder AS

  PROCEDURE initialize( p_int_aarray IN OUT NOCOPY BIN_INT_ARRAY, p_height BINARY_INTEGER := C_BITMAP_HEIGHT ) IS
    BEGIN
      FOR i IN 1 .. p_height LOOP
        p_int_aarray( i ) := NULL;
      END LOOP;
    END initialize;

  PROCEDURE initialize( p_int_matrix IN OUT NOCOPY BIN_INT_MATRIX, p_height BINARY_INTEGER := C_BITMAP_HEIGHT ) IS
    x bmap_segment_builder.BIN_INT_LIST := bmap_segment_builder.BIN_INT_LIST();
    BEGIN
      p_int_matrix := BIN_INT_MATRIX();
      FOR i IN 1 .. p_height LOOP
        p_int_matrix.EXTEND;
        p_int_matrix( i ) := x;
      END LOOP;
    END initialize;

  PROCEDURE store_bmap_segment(
    p_stor_table_name    VARCHAR2,
    p_bitmap_key         INTEGER,
    p_segment_H_pos      BINARY_INTEGER,
    p_segment_V_pos      BINARY_INTEGER,
    p_segment            bmap_segment_builder.BIN_INT_LIST
  ) IS
    BEGIN
      IF p_segment_H_pos IS NOT NULL AND p_segment_V_pos IS NOT NULL AND p_bitmap_key IS NOT NULL THEN
        bmap_persist.insertBitmapSegment( p_stor_table_name, p_bitmap_key, p_segment_V_pos, p_segment_H_pos, bmap_segment_builder.encode_and_convert( p_segment ) );
      END IF;
    END store_bmap_segment;

  PROCEDURE flush_bmap_segments(
    p_stor_table_name    VARCHAR2,
    p_bitmap_key         INTEGER,
    p_segment_value_list IN OUT NOCOPY BIN_INT_MATRIX,
    p_segment_H_pos_lst  IN OUT NOCOPY BIN_INT_ARRAY,
    p_segment_V_pos      BINARY_INTEGER := 1
  ) IS
    v_parent_segment_H_pos  BINARY_INTEGER;
    BEGIN
      store_bmap_segment( p_stor_table_name, p_bitmap_key, p_segment_H_pos_lst( p_segment_V_pos ), p_segment_V_pos, p_segment_value_list( p_segment_V_pos ) );
      IF p_segment_V_pos < C_BITMAP_HEIGHT THEN
        flush_bmap_segments( p_stor_table_name, p_bitmap_key, p_segment_value_list, p_segment_H_pos_lst, p_segment_V_pos + 1 );
      END IF;
      PRAGMA INLINE (initialize, 'YES');
      initialize( p_segment_H_pos_lst );
      PRAGMA INLINE (initialize, 'YES');
      initialize( p_segment_value_list );
    END flush_bmap_segments;

  PROCEDURE build_or_store_bmap_segment(
    p_stor_table_name               VARCHAR2,
    p_bitmap_key                    INTEGER,
    p_bit_pos                       INTEGER,
    p_processing_segm_H_pos_lst IN OUT NOCOPY BIN_INT_ARRAY,
    p_segment_int_list              IN OUT NOCOPY BIN_INT_MATRIX,
    p_current_segment_V_pos         BINARY_INTEGER := 1
  ) IS
    v_current_segment_H_pos BINARY_INTEGER;
    v_is_segment_change     BOOLEAN;
    v_is_new_bmap           BOOLEAN;
    BEGIN
      v_is_new_bmap           :=           p_processing_segm_H_pos_lst( p_current_segment_V_pos ) IS NULL;
      v_is_segment_change     :=         ( p_processing_segm_H_pos_lst( p_current_segment_V_pos )!=CEIL( p_bit_pos / C_SEGMENT_CAPACITY ) );
      v_current_segment_H_pos := COALESCE( p_processing_segm_H_pos_lst( p_current_segment_V_pos ), CEIL( p_bit_pos / C_SEGMENT_CAPACITY ) );

      IF p_current_segment_V_pos < C_BITMAP_HEIGHT THEN
          build_or_store_bmap_segment( p_stor_table_name, p_bitmap_key, v_current_segment_H_pos, p_processing_segm_H_pos_lst, p_segment_int_list, p_current_segment_V_pos + 1 );
      END IF;
      IF v_is_segment_change THEN
        store_bmap_segment( p_stor_table_name, p_bitmap_key, v_current_segment_H_pos, p_current_segment_V_pos, p_segment_int_list( p_current_segment_V_pos ) );
        p_segment_int_list( p_current_segment_V_pos ).DELETE;
      END IF;
      p_segment_int_list( p_current_segment_V_pos ).EXTEND;
      p_segment_int_list( p_current_segment_V_pos )( p_segment_int_list( p_current_segment_V_pos ).LAST ) := MOD( p_bit_pos - 1, C_SEGMENT_CAPACITY ) + 1;
      p_processing_segm_H_pos_lst( p_current_segment_V_pos ) := v_current_segment_H_pos;

    END build_or_store_bmap_segment;

  PROCEDURE build_bitmaps(
    p_bit_list_crsr SYS_REFCURSOR,
    p_stor_table_name VARCHAR2
  ) IS
    v_segment_value_list BIN_INT_MATRIX;
    v_bitmap_key_lst     VARCHAR2_LIST;
    v_bit_elem_list      INT_LIST;
    v_segment_H_pos_lst  BIN_INT_ARRAY;
    v_prev_bmap_key      VARCHAR2(4000);
    BEGIN
      PRAGMA INLINE (initialize, 'YES');
      initialize( v_segment_value_list );
      PRAGMA INLINE (initialize, 'YES');
      initialize( v_segment_H_pos_lst );
      LOOP
        FETCH p_bit_list_crsr BULK COLLECT INTO v_bitmap_key_lst, v_bit_elem_list LIMIT bmap_segment_builder.C_SEGMENT_CAPACITY;
        FOR i IN 1 .. v_bit_elem_list.COUNT LOOP
          IF v_bitmap_key_lst(i) != v_prev_bmap_key THEN
            flush_bmap_segments( p_stor_table_name, v_prev_bmap_key, v_segment_value_list, v_segment_H_pos_lst );
          END IF;
          build_or_store_bmap_segment( p_stor_table_name, v_bitmap_key_lst(i), v_bit_elem_list(i), v_segment_H_pos_lst, v_segment_value_list );
          v_prev_bmap_key := v_bitmap_key_lst(i);
        END LOOP;
        IF v_bit_elem_list.COUNT < bmap_segment_builder.C_SEGMENT_CAPACITY OR CARDINALITY( v_bit_elem_list ) = 0 THEN
          flush_bmap_segments( p_stor_table_name, v_prev_bmap_key, v_segment_value_list, v_segment_H_pos_lst );
        END IF;
        EXIT WHEN p_bit_list_crsr%NOTFOUND;
      END LOOP;
    END build_bitmaps;

END bmap_builder;
/

SHOW ERRORS
/
