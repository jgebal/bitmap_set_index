ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE BODY bmap_oper AS

  C_BITMAP_HEIGHT    CONSTANT BINARY_INTEGER := bmap_builder.C_BITMAP_HEIGHT;
  FUNCTION int_list_to_csv(
    p_int_lst bmap_segment_builder.BIN_INT_LIST
  ) RETURN VARCHAR2 DETERMINISTIC IS
    v_result VARCHAR2(32767);
    i        BINARY_INTEGER;
    BEGIN
      IF p_int_lst IS NOT NULL AND p_int_lst.COUNT > 0 THEN
        i := p_int_lst.FIRST;
        LOOP
          v_result := v_result || p_int_lst(i);
          EXIT WHEN i = p_int_lst.LAST;
          v_result := v_result || ',';
          i := i + 1;
        END LOOP;
      END IF;
      RETURN v_result;
    END int_list_to_csv;

  FUNCTION bit_and_segments_level(
    p_stor_table_name  VARCHAR2,
    p_left_bitmap_key  NUMBER,
    p_right_bitmap_key NUMBER,
    p_segment_H_pos_lst bmap_segment_builder.BIN_INT_LIST DEFAULT NULL,
    p_segment_V_pos    INTEGER := C_BITMAP_HEIGHT
  ) RETURN INTEGER IS
    v_crsr SYS_REFCURSOR;
    v_left_bmap         STOR_BMAP_SEGMENT;
    v_right_bmap        STOR_BMAP_SEGMENT;
    v_common_bits       bmap_segment_builder.BIN_INT_LIST;
    v_segment_H_pos     INTEGER;
    v_common_rows_count INTEGER := 0;
    BEGIN
      DBMS_OUTPUT.PUT_LINE('operating on p_segment_V_pos = '||p_segment_V_pos);
      DBMS_OUTPUT.PUT_LINE('p_segment_H_pos_lst = '||int_list_to_csv(p_segment_H_pos_lst));
      OPEN v_crsr FOR
      'SELECT t_left.bmap left_bmap, t_right.bmap right_bmap, bmap_h_pos
         FROM '||p_stor_table_name||' t_left
         JOIN '||p_stor_table_name||' t_right USING (bmap_h_pos, bmap_v_pos)
        WHERE t_left.bitmap_key = :p_left_bitmap_key
          AND t_right.bitmap_key = :p_right_bitmap_key'||
      CASE WHEN int_list_to_csv(p_segment_H_pos_lst) IS NOT NULL
      THEN '
           AND bmap_h_pos IN ('||int_list_to_csv(p_segment_H_pos_lst)||')' END || '
           AND bmap_v_pos = :segment_V_pos'
      USING p_left_bitmap_key, p_right_bitmap_key, p_segment_V_pos;
      LOOP
        FETCH v_crsr INTO v_left_bmap, v_right_bmap, v_segment_H_pos;
        EXIT WHEN v_crsr%NOTFOUND;
        v_common_bits := bmap_segment_builder.decode_bmap_segment( bmap_segment_builder.segment_bit_and( v_left_bmap, v_right_bmap ) );
        IF p_segment_V_pos = 1 THEN
          v_common_rows_count := v_common_rows_count + v_common_bits.COUNT;
        ELSIF v_common_bits.COUNT > 0 THEN
          v_common_rows_count := bit_and_segments_level( p_stor_table_name, p_left_bitmap_key, p_right_bitmap_key, v_common_bits, p_segment_V_pos - 1);
        END IF;
      END LOOP;
      RETURN v_common_rows_count;
    END bit_and_segments_level;

--RETURN NUMBER OF ROWS THAT ARE COMMON FOR BOTH
  FUNCTION bit_and(
    p_stor_table_name VARCHAR2,
    p_left_bitmap_key NUMBER,
    p_right_bitmap_key NUMBER
  ) RETURN INTEGER IS
    BEGIN
      RETURN bit_and_segments_level( p_stor_table_name, p_left_bitmap_key, p_right_bitmap_key);
    END bit_and;


END bmap_oper;
/

SHOW ERRORS
/
