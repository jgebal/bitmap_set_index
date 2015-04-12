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

  PROCEDURE build_and_store_bmap_segment(
    p_stor_table_name    VARCHAR2,
    p_bitmap_key         INTEGER,
    p_bit_elem_list      INT_LIST,
    p_elem_idx           BINARY_INTEGER,
    p_segment_H_pos_lst  IN OUT NOCOPY BIN_INT_ARRAY,
    p_segment_int_list   IN OUT NOCOPY BIN_INT_MATRIX,
    p_force_store        BOOLEAN := FALSE,
    p_segment_V_pos      BINARY_INTEGER := 1
  ) IS
    v_segment_H_pos     BINARY_INTEGER;
    v_parent_list       INT_LIST := INT_LIST( );
    v_encoded_segment   bmap_segment_builder.BMAP_SEGMENT;
    v_segment           STOR_BMAP_SEGMENT := STOR_BMAP_SEGMENT();
    BEGIN
      v_segment_H_pos := CEIL( p_bit_elem_list( p_elem_idx ) / bmap_segment_builder.C_SEGMENT_CAPACITY );
      IF v_segment_H_pos != p_segment_H_pos_lst( p_segment_V_pos ) OR p_force_store THEN
        bmap_segment_builder.encode_bmap_segment( p_segment_int_list( p_segment_V_pos ), v_encoded_segment );
        bmap_segment_builder.convert_for_storage( v_encoded_segment, v_segment );
        bmap_persist.insertBitmapSegment(
            p_stor_table_name,
            p_bitmap_key,
            p_segment_V_pos,
            COALESCE( p_segment_H_pos_lst( p_segment_V_pos ), v_segment_H_pos ),
            v_segment
        );
        v_parent_list.EXTEND;
        v_parent_list( v_parent_list.LAST ) := v_segment_H_pos;
        IF p_segment_V_pos < C_BITMAP_HEIGHT THEN
          build_and_store_bmap_segment( p_stor_table_name, p_bitmap_key, v_parent_list, v_parent_list.LAST, p_segment_H_pos_lst, p_segment_int_list, p_force_store, p_segment_V_pos + 1 );
        END IF;
        p_segment_int_list( p_segment_V_pos ).DELETE;
      ELSE
        p_segment_int_list( p_segment_V_pos ).EXTEND;
        p_segment_int_list( p_segment_V_pos )( p_segment_int_list( p_segment_V_pos ).LAST ) := MOD( p_bit_elem_list( p_elem_idx ), bmap_segment_builder.C_SEGMENT_CAPACITY );
      END IF;
      p_segment_H_pos_lst( p_segment_V_pos ) := v_segment_H_pos;
    END build_and_store_bmap_segment;

  PROCEDURE build_bitmaps(
    p_bit_list_crsr SYS_REFCURSOR,
    p_stor_table_name VARCHAR2
  ) IS
    v_segment_int_list   BIN_INT_MATRIX;
    v_bitmap_key_lst     VARCHAR2_LIST;
    v_bit_elem_list      INT_LIST;
    v_segment_H_pos_lst  BIN_INT_ARRAY;
    v_prev_bmap_key      VARCHAR2(4000);
    BEGIN
      PRAGMA INLINE (initialize, 'YES');
      initialize( v_segment_int_list );
      PRAGMA INLINE (initialize, 'YES');
      initialize( v_segment_H_pos_lst );
      LOOP
        FETCH p_bit_list_crsr BULK COLLECT INTO v_bitmap_key_lst, v_bit_elem_list LIMIT bmap_segment_builder.C_SEGMENT_CAPACITY;
        EXIT WHEN CARDINALITY( v_bit_elem_list ) = 0;
        FOR i IN v_bit_elem_list.FIRST .. v_bit_elem_list.LAST LOOP
          IF v_bitmap_key_lst(i) != v_prev_bmap_key THEN
            build_and_store_bmap_segment( p_stor_table_name, v_prev_bmap_key, v_bit_elem_list, i, v_segment_H_pos_lst, v_segment_int_list, TRUE );
            PRAGMA INLINE (initialize, 'YES');
            initialize( v_segment_int_list );
            PRAGMA INLINE (initialize, 'YES');
            initialize( v_segment_H_pos_lst );
          END IF;
          build_and_store_bmap_segment( p_stor_table_name, v_bitmap_key_lst(i), v_bit_elem_list, i, v_segment_H_pos_lst, v_segment_int_list );
          v_prev_bmap_key := v_bitmap_key_lst(i);
        END LOOP;
        EXIT WHEN p_bit_list_crsr%NOTFOUND;
      END LOOP;
    END build_bitmaps;

END bmap_builder;
/

SHOW ERRORS
/
