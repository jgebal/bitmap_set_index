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
      'SELECT t_left.segment_bmap left_bmap, t_right.segment_bmap right_bmap, segment_h_pos
         FROM '||p_stor_table_name||' t_left
         JOIN '||p_stor_table_name||' t_right USING (segment_h_pos, segment_v_pos)
        WHERE t_left.bmap_key = :p_left_bitmap_key
          AND t_right.bmap_key = :p_right_bitmap_key'||
      CASE WHEN int_list_to_csv(p_segment_H_pos_lst) IS NOT NULL
        THEN '
           AND segment_h_pos IN ('||int_list_to_csv(p_segment_H_pos_lst)||')' END || '
           AND segment_v_pos = :segment_V_pos'
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
    v_bmap_anydata ANYDATA;
    BEGIN
      EXECUTE IMMEDIATE
      'SELECT segment_bmap
       FROM '||p_stor_table_name||'
        WHERE bmap_key = :bitmap_key
           AND segment_h_pos = :segment_H_pos
           AND segment_v_pos = :segment_V_pos'
      INTO v_bmap_anydata USING p_bitmap_key, p_segment_H_pos, p_segment_V_pos;
      IF v_bmap_anydata.GetCollection( v_segment ) != DBMS_TYPES.SUCCESS THEN
        raise_application_error(-20000, 'Unable to fetch data from segment');
      END IF;
      RETURN v_segment;
    END get_segment;

  PROCEDURE insert_segment(
    p_stor_table_name VARCHAR2,
    p_bitmap_key    INTEGER,
    p_segment_V_pos INTEGER,
    p_segment_H_pos INTEGER,
    p_segment       STOR_BMAP_SEGMENT
  ) IS
    v_bmap_anydata ANYDATA;
  BEGIN
    v_bmap_anydata := anydata.ConvertCollection(  p_segment );
    EXECUTE IMMEDIATE
     'INSERT
        INTO '||p_stor_table_name||'
             ( bmap_key, segment_h_pos, segment_v_pos, segment_bmap  )
      VALUES ( :p_bitmap_key, :p_segment_H_pos, :p_segment_V_pos, :v_bmap_anydata )'
    USING p_bitmap_key, p_segment_H_pos, p_segment_V_pos, v_bmap_anydata;
  END insert_segment;

END bmap_persist;
/

SHOW ERRORS
/
