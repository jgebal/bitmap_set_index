CREATE OR REPLACE PACKAGE BODY bmap_persist AS

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

  FUNCTION get_segment_pairs_cursor(
    p_stor_table_name  VARCHAR2,
    p_left_bitmap_key  NUMBER,
    p_right_bitmap_key NUMBER,
    p_segment_H_pos_lst bmap_segment_builder.BIN_INT_LIST,
    p_segment_V_pos    INTEGER
  ) RETURN SYS_REFCURSOR IS
    v_crsr SYS_REFCURSOR;
    BEGIN
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
      RETURN v_crsr;
    END get_segment_pairs_cursor;

  FUNCTION get_segment(
    p_stor_table_name  VARCHAR2,
    p_bitmap_key       NUMBER,
    p_segment_H_pos    INTEGER,
    p_segment_V_pos    INTEGER
  ) RETURN STOR_BMAP_SEGMENT IS
    v_segment STOR_BMAP_SEGMENT;
    BEGIN
      EXECUTE IMMEDIATE
      'SELECT t_left.bmap left_bmap, t_right.bmap right_bmap, bmap_h_pos
       FROM '||p_stor_table_name||' t_left
         JOIN '||p_stor_table_name||' t_right USING (bmap_h_pos, bmap_v_pos)
        WHERE t_left.bitmap_key = :p_left_bitmap_key
          AND t_right.bitmap_key = :p_right_bitmap_key
           AND bmap_h_pos = :segment_H_pos
           AND bmap_v_pos = :segment_V_pos'
      INTO v_segment USING p_bitmap_key, p_segment_H_pos, p_segment_V_pos;
      RETURN v_segment;
    END get_segment;

  PROCEDURE insert_segment(
    p_stor_table_name VARCHAR2,
    p_bitmap_key    INTEGER,
    p_segment_V_pos INTEGER,
    p_segment_H_pos INTEGER,
    p_segment       STOR_BMAP_SEGMENT
  ) IS
  BEGIN
    EXECUTE IMMEDIATE
     'INSERT
        INTO '||p_stor_table_name||'
             ( BITMAP_KEY, BMAP_H_POS, BMAP_V_POS, BMAP )
      VALUES ( :p_bitmap_key, :p_segment_H_pos, :p_segment_V_pos, :v_bmap_varray )'
    USING p_bitmap_key, p_segment_H_pos, p_segment_V_pos, p_segment;
  END insert_segment;

END bmap_persist;
/

SHOW ERRORS
/
