CREATE OR REPLACE PACKAGE BODY bmap_oper AS

  C_BITMAP_HEIGHT    CONSTANT BINARY_INTEGER := bmap_builder.C_BITMAP_HEIGHT;

  FUNCTION bit_and_segments_level_count(
    p_stor_table_name  VARCHAR2,
    p_left_bitmap_key  NUMBER,
    p_right_bitmap_key NUMBER,
    p_segment_H_pos_lst bmap_segment_builder.BIN_INT_LIST DEFAULT NULL,
    p_segment_V_pos    INTEGER := C_BITMAP_HEIGHT
  ) RETURN INTEGER;

  FUNCTION bit_and_segments_level_count(
    p_stor_table_name  VARCHAR2,
    p_left_bitmap_key  NUMBER,
    p_right_bitmap_key NUMBER,
    p_segment_H_pos_lst bmap_segment_builder.BIN_INT_LIST DEFAULT NULL,
    p_segment_V_pos    INTEGER := C_BITMAP_HEIGHT
  ) RETURN INTEGER IS
    v_crsr SYS_REFCURSOR;
    v_left_bmap_data    ANYDATA;
    v_right_bmap_data   ANYDATA;
    v_left_bmap         STOR_BMAP_SEGMENT;
    v_right_bmap        STOR_BMAP_SEGMENT;
    v_common_bits       bmap_segment_builder.BIN_INT_LIST;
    v_segment_H_pos     INTEGER;
    v_common_rows_count INTEGER := 0;
    BEGIN
      v_crsr := bmap_persist.get_segment_pairs_cursor(p_stor_table_name, p_left_bitmap_key, p_right_bitmap_key, p_segment_H_pos_lst,p_segment_V_pos);
      LOOP
        FETCH v_crsr INTO v_left_bmap_data, v_right_bmap_data, v_segment_H_pos;
        EXIT WHEN v_crsr%NOTFOUND;
        IF v_left_bmap_data.GetCollection( v_left_bmap ) != DBMS_TYPES.SUCCESS THEN
          raise_application_error(-20000, 'Unable to fetch data from segment');
        END IF;
        IF v_right_bmap_data.GetCollection( v_right_bmap ) != DBMS_TYPES.SUCCESS THEN
          raise_application_error(-20000, 'Unable to fetch data from segment');
        END IF;
        v_common_bits := bmap_segment_builder.decode_bmap_segment( bmap_segment_builder.segment_bit_and( v_left_bmap, v_right_bmap ) );
        IF p_segment_V_pos = 1 THEN
          v_common_rows_count := v_common_rows_count + v_common_bits.COUNT;
        ELSIF v_common_bits.COUNT > 0 THEN
          v_common_rows_count := bit_and_segments_level_count( p_stor_table_name, p_left_bitmap_key, p_right_bitmap_key, v_common_bits, p_segment_V_pos - 1);
        END IF;
      END LOOP;
      CLOSE v_crsr;
      RETURN v_common_rows_count;
    END bit_and_segments_level_count;

--RETURN NUMBER OF ROWS THAT ARE COMMON FOR BOTH
  FUNCTION bit_and(
    p_stor_table_name VARCHAR2,
    p_left_bitmap_key NUMBER,
    p_right_bitmap_key NUMBER
  ) RETURN INTEGER IS
    BEGIN
      RETURN bit_and_segments_level_count( p_stor_table_name, p_left_bitmap_key, p_right_bitmap_key);
    END bit_and;


END bmap_oper;
/

SHOW ERRORS
/
