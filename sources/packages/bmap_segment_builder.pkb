ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE BODY bmap_segment_builder AS

--PRIVATE SPECIFICATIONS

  ge_subscript_beyond_count EXCEPTION;
  PRAGMA EXCEPTION_INIT(ge_subscript_beyond_count,-6533);

  FUNCTION init_bit_values_in_byte RETURN BMAP_SEGMENT;

  gc_bit_values_in_byte    CONSTANT BMAP_SEGMENT := init_bit_values_in_byte();

  PROCEDURE init_if_needed( p_int_matrix IN OUT NOCOPY BMAP_SEGMENT ) IS
    c_height BINARY_INTEGER := C_SEGMENT_HEIGHT;
    x BMAP_SEGMENT_LEVEL;
    BEGIN
      IF p_int_matrix IS NULL OR p_int_matrix.COUNT = 0 THEN
        FOR i IN 1 .. c_height LOOP
          p_int_matrix( i ) := x;
        END LOOP;
      END IF;
    END init_if_needed;

  FUNCTION bitor(
    p_left IN BINARY_INTEGER,
    p_right IN BINARY_INTEGER
  ) RETURN BINARY_INTEGER DETERMINISTIC IS
    BEGIN
      RETURN p_left + (p_right - BITAND(p_left, p_right));
    END bitor;

  PROCEDURE set_bit_in_element(
    p_bitmap_tree_level  IN OUT NOCOPY BMAP_SEGMENT_LEVEL,
    p_bit_number                       BINARY_INTEGER
  ) IS
    v_bit_number_in_segment BINARY_INTEGER := 0;
    v_segment_number        BINARY_INTEGER := 0;
    BEGIN
      v_bit_number_in_segment := MOD( p_bit_number - 1, C_ELEMENT_CAPACITY );
      v_segment_number := CEIL( p_bit_number / C_ELEMENT_CAPACITY );
      IF NOT p_bitmap_tree_level.EXISTS( v_segment_number ) THEN
        p_bitmap_tree_level( v_segment_number ) := POWER( 2, v_bit_number_in_segment );
      ELSE
        PRAGMA INLINE(bitor,'YES');
        p_bitmap_tree_level( v_segment_number ) := bitor( p_bitmap_tree_level( v_segment_number ), POWER( 2, v_bit_number_in_segment ) );
      END IF;
    END set_bit_in_element;

  PROCEDURE encode_leaf_segment_level(
    p_bmap_segment_level IN OUT NOCOPY BMAP_SEGMENT_LEVEL,
    p_bit_numbers_set    BIN_INT_LIST
  ) IS
    v_bit_number_idx BINARY_INTEGER;
    BEGIN
      v_bit_number_idx := p_bit_numbers_set.FIRST;
      LOOP
        EXIT WHEN v_bit_number_idx IS NULL;
        PRAGMA INLINE(set_bit_in_element,'YES');
        set_bit_in_element( p_bmap_segment_level, p_bit_numbers_set( v_bit_number_idx ) );
        v_bit_number_idx := p_bit_numbers_set.NEXT( v_bit_number_idx );
      END LOOP;
    END encode_leaf_segment_level;

  PROCEDURE encode_segment_level(
    p_bmap_segment          IN OUT NOCOPY BMAP_SEGMENT,
    p_bmap_segment_level_no BINARY_INTEGER
  ) IS
    v_node BINARY_INTEGER;
    BEGIN
      v_node := p_bmap_segment( p_bmap_segment_level_no - 1 ).FIRST;
      LOOP
        EXIT WHEN v_node IS NULL;
        PRAGMA INLINE(set_bit_in_element,'YES');
        set_bit_in_element( p_bmap_segment( p_bmap_segment_level_no ), v_node );
        v_node := p_bmap_segment( p_bmap_segment_level_no - 1 ).NEXT( v_node );
      END LOOP;
    END encode_segment_level;

  PROCEDURE encode_bmap_segment(
    p_bit_no_list  BIN_INT_LIST,
    p_bmap_segment IN OUT NOCOPY BMAP_SEGMENT
  ) IS
    BEGIN
      IF p_bit_no_list IS NULL OR p_bit_no_list.COUNT = 0 THEN
        RETURN;
      END IF;

      init_if_needed( p_bmap_segment );
      PRAGMA INLINE(encode_leaf_segment_level, 'YES');
      encode_leaf_segment_level( p_bmap_segment( 1 ), p_bit_no_list );
      FOR bit_map_level_number IN 2 .. C_SEGMENT_HEIGHT LOOP
        PRAGMA INLINE(encode_segment_level, 'YES');
        encode_segment_level( p_bmap_segment, bit_map_level_number );
      END LOOP;

    END encode_bmap_segment;

  FUNCTION encode_bmap_segment(
    p_bit_no_list BIN_INT_LIST
  ) RETURN BMAP_SEGMENT IS
    v_bmap_segment    BMAP_SEGMENT;
    BEGIN
      encode_bmap_segment( p_bit_no_list, v_bmap_segment );
      RETURN v_bmap_segment;
    END encode_bmap_segment;


  PROCEDURE decode_bmap_element(
    p_element_value   BINARY_INTEGER,
    p_bit_number_list IN OUT NOCOPY BIN_INT_LIST,
    p_bit_pos_offset  BINARY_INTEGER DEFAULT 0
  ) IS
    v_byte_values_list BMAP_SEGMENT_LEVEL;
    v_remaining_value  BINARY_INTEGER;
    v_bit_pos          BINARY_INTEGER := 0;
    v_byte_values_idx  BINARY_INTEGER;
    BEGIN
      v_remaining_value := p_element_value;
      WHILE v_remaining_value != 0 LOOP
        v_byte_values_idx := MOD( v_remaining_value, 1024 );
        IF v_byte_values_idx > 0 THEN
          v_byte_values_list := gc_bit_values_in_byte( v_byte_values_idx );
          FOR i IN v_byte_values_list.FIRST .. v_byte_values_list.LAST LOOP
            p_bit_number_list.EXTEND;
            p_bit_number_list( p_bit_number_list.LAST ) := v_byte_values_list(i)+v_bit_pos+p_bit_pos_offset;
          END LOOP;
        END IF;
        v_remaining_value := FLOOR(v_remaining_value / 1024);
        v_bit_pos := v_bit_pos + 10;
      END LOOP;
    END decode_bmap_element;

  FUNCTION decode_bmap_element(
    p_element_value  BINARY_INTEGER
  ) RETURN BIN_INT_LIST IS
    v_bit_numbers_list BIN_INT_LIST := BIN_INT_LIST( );
    BEGIN
      decode_bmap_element(p_element_value,v_bit_numbers_list);
      RETURN v_bit_numbers_list;
    END decode_bmap_element;

  FUNCTION decode_bmap_segment_level(
    p_bmap_element_list BMAP_SEGMENT_LEVEL
  ) RETURN BIN_INT_LIST IS
    v_bit_numbers_list BIN_INT_LIST := BIN_INT_LIST( );
    v_byte_values_list BIN_INT_LIST;
    v_element_position BINARY_INTEGER;
    v_remaining_value  BINARY_INTEGER;
    v_bit_pos_offset   BINARY_INTEGER;
    v_byte_values_idx  BINARY_INTEGER;
    BEGIN
      v_element_position := p_bmap_element_list.FIRST;
      LOOP
        EXIT WHEN v_element_position IS NULL;
        v_bit_pos_offset := C_ELEMENT_CAPACITY * ( v_element_position - 1 );

        decode_bmap_element( p_bmap_element_list( v_element_position ), v_bit_numbers_list, v_bit_pos_offset );
        v_element_position := p_bmap_element_list.NEXT( v_element_position );
      END LOOP;
      RETURN v_bit_numbers_list;
    END decode_bmap_segment_level;

  FUNCTION decode_bmap_segment(
    p_bitmap_tree BMAP_SEGMENT
  ) RETURN BIN_INT_LIST IS
    BEGIN
      IF p_bitmap_tree IS NULL OR p_bitmap_tree.COUNT = 0 THEN
        RETURN BIN_INT_LIST( );
      END IF;

      RETURN decode_bmap_segment_level( p_bitmap_tree(1) );
    END decode_bmap_segment;

  PROCEDURE segment_level_bit_and(
    p_bmap_left                 BMAP_SEGMENT,
    p_bmap_right                BMAP_SEGMENT,
    p_level                     BINARY_INTEGER,
    p_node                      BINARY_INTEGER,
    p_bmap_result IN OUT NOCOPY BMAP_SEGMENT
  ) IS
    v_node_value      BINARY_INTEGER;
    v_child_node_list BIN_INT_LIST;
    BEGIN
      v_node_value := BITAND( p_bmap_left( p_level )( p_node ), p_bmap_right( p_level )( p_node ) );
      IF v_node_value > 0 THEN
        p_bmap_result( p_level )( p_node ) := v_node_value;
        IF p_level - 1 > 0 THEN
          v_child_node_list := decode_bmap_element( v_node_value );
          FOR i IN 1 .. CARDINALITY( v_child_node_list ) LOOP
            segment_level_bit_and(
                p_bmap_left,
                p_bmap_right,
                p_level - 1,
                v_child_node_list(i) + C_ELEMENT_CAPACITY * ( p_node - 1 ),
                p_bmap_result
            );
          END LOOP;
        END IF;
      END IF;
    END segment_level_bit_and;

  PROCEDURE segment_level_bit_or(
    p_bmap_left                 BMAP_SEGMENT,
    p_bmap_right                BMAP_SEGMENT,
    p_level                     BINARY_INTEGER,
    p_node                      BINARY_INTEGER,
    p_bmap_result IN OUT NOCOPY BMAP_SEGMENT
  ) IS
    v_node_value      BINARY_INTEGER;
    v_child_node_list BIN_INT_LIST;
    BEGIN
      IF NOT p_bmap_left( p_level ).EXISTS( p_node ) THEN
        v_node_value := p_bmap_right( p_level )( p_node );
      ELSIF NOT p_bmap_right( p_level ).EXISTS( p_node ) THEN
        v_node_value := p_bmap_left( p_level )( p_node );
      ELSE
        PRAGMA INLINE (bitor, 'YES');
        v_node_value := bitor( p_bmap_left( p_level )( p_node ), p_bmap_right( p_level )( p_node ) );
      END IF;
      IF v_node_value > 0 THEN
        p_bmap_result( p_level )( p_node ) := v_node_value;
        IF p_level -1 > 0 THEN
          v_child_node_list := decode_bmap_element( v_node_value );
          FOR i IN 1 .. CARDINALITY( v_child_node_list ) LOOP
            segment_level_bit_or(
                p_bmap_left,
                p_bmap_right,
                p_level - 1,
                v_child_node_list(i) + C_ELEMENT_CAPACITY * ( p_node - 1 ),
                p_bmap_result
            );
          END LOOP;
        END IF;
      END IF;
    END segment_level_bit_or;

  PROCEDURE segment_level_bit_minus(
    p_bmap_left   IN OUT NOCOPY BMAP_SEGMENT,
    p_bmap_right                BMAP_SEGMENT,
    p_level                     BINARY_INTEGER,
    p_node                      BINARY_INTEGER
  ) IS
    v_node_value      BINARY_INTEGER;
    v_child_node_list BIN_INT_LIST;
    i                 BINARY_INTEGER;
    BEGIN
      v_node_value := p_bmap_left( p_level )( p_node ) - BITAND( p_bmap_left( p_level )( p_node ), p_bmap_right( p_level )( p_node ) );
      IF p_level - 1 > 0 THEN
        v_child_node_list := decode_bmap_element( p_bmap_left( p_level )( p_node ) );
        FOR i IN 1 .. CARDINALITY( v_child_node_list ) LOOP
          segment_level_bit_minus(
              p_bmap_left,
              p_bmap_right,
              p_level - 1,
              v_child_node_list(i) + C_ELEMENT_CAPACITY * ( p_node - 1 )
          );
        END LOOP;
      END IF;
      IF v_node_value > 0 THEN
        p_bmap_left( p_level )( p_node ) := v_node_value;
      ELSE
        p_bmap_left( p_level ).DELETE( p_node );
      END IF;
    EXCEPTION WHEN NO_DATA_FOUND OR ge_subscript_beyond_count THEN
      NULL;
    END segment_level_bit_minus;

  FUNCTION segment_bit_and(
    p_bmap_left  BMAP_SEGMENT,
    p_bmap_right BMAP_SEGMENT
  ) RETURN BMAP_SEGMENT IS
    v_result_bmap   BMAP_SEGMENT;
    BEGIN
      IF p_bmap_left IS NULL OR p_bmap_right IS NULL OR p_bmap_left.COUNT = 0 OR
         p_bmap_right.COUNT = 0 THEN
        RETURN v_result_bmap;
      END IF;
      init_if_needed( v_result_bmap );
      segment_level_bit_and(
          p_bmap_left,
          p_bmap_right,
          C_SEGMENT_HEIGHT,
          1,
          v_result_bmap );
      RETURN v_result_bmap;
    END segment_bit_and;

  FUNCTION segment_bit_or(
    p_bmap_left  BMAP_SEGMENT,
    p_bmap_right BMAP_SEGMENT
  ) RETURN BMAP_SEGMENT IS
    v_result_bmap   BMAP_SEGMENT;
    BEGIN
      IF p_bmap_left IS NULL OR p_bmap_right IS NULL OR p_bmap_left.COUNT = 0 OR
         p_bmap_right.COUNT = 0 THEN
        RETURN v_result_bmap;
      END IF;
      init_if_needed( v_result_bmap );
      segment_level_bit_or(
          p_bmap_left,
          p_bmap_right,
          C_SEGMENT_HEIGHT,
          1,
          v_result_bmap );
      RETURN v_result_bmap;
    END segment_bit_or;

  FUNCTION segment_bit_minus(
    p_bmap_left  BMAP_SEGMENT,
    p_bmap_right BMAP_SEGMENT
  ) RETURN BMAP_SEGMENT IS
    v_result_bmap   BMAP_SEGMENT := p_bmap_left;
    BEGIN
      IF p_bmap_left IS NULL OR p_bmap_right IS NULL OR p_bmap_left.COUNT = 0 OR
         p_bmap_right.COUNT = 0 THEN
        RETURN v_result_bmap;
      END IF;
      segment_level_bit_minus( v_result_bmap, p_bmap_right, C_SEGMENT_HEIGHT, 1 );
      RETURN v_result_bmap;
    END segment_bit_minus;

  PROCEDURE convert_for_storage(
    p_bitmap_list BMAP_SEGMENT,
    p_level_list  IN OUT NOCOPY STOR_BMAP_SEGMENT
  ) IS
    v_node_list  STOR_BMAP_LEVEL   := STOR_BMAP_LEVEL();
    v_level_list STOR_BMAP_SEGMENT := STOR_BMAP_SEGMENT();
    v_node       STOR_BMAP_NODE    := STOR_BMAP_NODE(0,0);
    BEGIN
      p_level_list.DELETE;
      IF NOT (p_bitmap_list IS NULL OR p_bitmap_list.COUNT = 0) THEN
        p_level_list.EXTEND( p_bitmap_list.COUNT );
        FOR i IN p_bitmap_list.FIRST .. p_bitmap_list.LAST LOOP
          v_node_list.EXTEND( p_bitmap_list(i).COUNT );
          v_node.node_index := p_bitmap_list(i).FIRST;
          FOR j IN v_node_list.FIRST .. v_node_list.LAST LOOP
            v_node.node_value := p_bitmap_list(i)( v_node.node_index );
            v_node_list( j ) := v_node;
            v_node.node_index := p_bitmap_list(i).NEXT( v_node.node_index );
          END LOOP;
          p_level_list( i ) := v_node_list;
          v_node_list.DELETE;
        END LOOP;
      END IF;
    END convert_for_storage;

  FUNCTION convert_for_storage(
    p_bitmap_list BMAP_SEGMENT
  ) RETURN STOR_BMAP_SEGMENT IS
    v_level_list STOR_BMAP_SEGMENT := STOR_BMAP_SEGMENT();
    BEGIN
      convert_for_storage( p_bitmap_list, v_level_list );
      RETURN v_level_list;
    END convert_for_storage;

  FUNCTION convert_for_processing(
    p_bitmap_list STOR_BMAP_SEGMENT
  ) RETURN BMAP_SEGMENT IS
    v_level_list BMAP_SEGMENT;
    j            BINARY_INTEGER;
    BEGIN
      IF NOT (p_bitmap_list IS NULL OR p_bitmap_list.COUNT = 0) THEN
        FOR i IN p_bitmap_list.FIRST .. p_bitmap_list.LAST LOOP
          FOR j IN p_bitmap_list(i).FIRST .. p_bitmap_list(i).LAST LOOP
            v_level_list(i)(p_bitmap_list(i)(j).node_index) := p_bitmap_list(i)(j).node_value;
          END LOOP;
        END LOOP;
      END IF;
      RETURN v_level_list;
    END convert_for_processing;

  FUNCTION segment_bit_and(
    p_bmap_left  STOR_BMAP_SEGMENT,
    p_bmap_right STOR_BMAP_SEGMENT
  ) RETURN BMAP_SEGMENT
  IS
    BEGIN
      RETURN segment_bit_and( convert_for_processing( p_bmap_left ), convert_for_processing( p_bmap_right ) );
    END segment_bit_and;

  FUNCTION encode_and_convert(
    p_bit_no_list BIN_INT_LIST
  ) RETURN STOR_BMAP_SEGMENT
  IS
    BEGIN
      RETURN convert_for_storage( encode_bmap_segment( p_bit_no_list ) );
    END encode_and_convert;


/**
 * Package constant initialization function - do not modify this code
 *  if you dont know what you're doing
 * Function returns a PL/SQL TABLE in format:
 *  initBitValuesInByte('00') -> ()
 *  initBitValuesInByte('01') -> (1)
 * ...
 *  initBitValuesInByte('0F') -> (1,2,3,4,5,6,7,8)
 * ...
 *  initBitValuesInByte('FF') -> (1,2,3,4,5,6,7,8..., 16)
 */
  FUNCTION init_bit_values_in_byte RETURN BMAP_SEGMENT
  IS
    v_low_values_in_byte  BMAP_SEGMENT;
    v_high_values_in_byte BMAP_SEGMENT;
    v_result              BMAP_SEGMENT;
    idx                   BINARY_INTEGER;
    FUNCTION get_bmap_node_list(p_lst int_list) RETURN BMAP_SEGMENT_LEVEL IS
      v_res BMAP_SEGMENT_LEVEL;
      BEGIN
        FOR i IN 1 .. p_lst.COUNT loop
          v_res(i) := p_lst(i);
        END LOOP;
        RETURN v_res;
      END get_bmap_node_list;
    FUNCTION multiset_union_all(p_left BMAP_SEGMENT_LEVEL, p_right BMAP_SEGMENT_LEVEL) RETURN BMAP_SEGMENT_LEVEL IS
      v_res BMAP_SEGMENT_LEVEL;
      i BINARY_INTEGER;
      j BINARY_INTEGER := 0;
      BEGIN
        i := p_left.FIRST;
        LOOP
          EXIT WHEN i IS NULL;
          j := j + 1;
          v_res(j) := p_left(i);
          i := p_left.NEXT(i);
        END LOOP;
        i := p_right.FIRST;
        LOOP
          EXIT WHEN i IS NULL;
          j := j + 1;
          v_res(j) := p_right(i);
          i := p_right.NEXT(i);
        END LOOP;
        RETURN v_res;
      END multiset_union_all;
    BEGIN
      v_low_values_in_byte( 1) := get_bmap_node_list(INT_LIST(1));
      v_low_values_in_byte( 2) := get_bmap_node_list(INT_LIST(2));
      v_low_values_in_byte( 3) := get_bmap_node_list(INT_LIST(1,2));
      v_low_values_in_byte( 4) := get_bmap_node_list(INT_LIST(3));
      v_low_values_in_byte( 5) := get_bmap_node_list(INT_LIST(1,3));
      v_low_values_in_byte( 6) := get_bmap_node_list(INT_LIST(2,3));
      v_low_values_in_byte( 7) := get_bmap_node_list(INT_LIST(1,2,3));
      v_low_values_in_byte( 8) := get_bmap_node_list(INT_LIST(4));
      v_low_values_in_byte( 9) := get_bmap_node_list(INT_LIST(1,4));
      v_low_values_in_byte(10) := get_bmap_node_list(INT_LIST(2,4));
      v_low_values_in_byte(11) := get_bmap_node_list(INT_LIST(1,2,4));
      v_low_values_in_byte(12) := get_bmap_node_list(INT_LIST(3,4));
      v_low_values_in_byte(13) := get_bmap_node_list(INT_LIST(1,3,4));
      v_low_values_in_byte(14) := get_bmap_node_list(INT_LIST(2,3,4));
      v_low_values_in_byte(15) := get_bmap_node_list(INT_LIST(1,2,3,4));
      v_low_values_in_byte(16) := get_bmap_node_list(INT_LIST(5));
      v_low_values_in_byte(17) := get_bmap_node_list(INT_LIST(1,5));
      v_low_values_in_byte(18) := get_bmap_node_list(INT_LIST(2,5));
      v_low_values_in_byte(19) := get_bmap_node_list(INT_LIST(1,2,5));
      v_low_values_in_byte(20) := get_bmap_node_list(INT_LIST(3,5));
      v_low_values_in_byte(21) := get_bmap_node_list(INT_LIST(1,3,5));
      v_low_values_in_byte(22) := get_bmap_node_list(INT_LIST(2,3,5));
      v_low_values_in_byte(23) := get_bmap_node_list(INT_LIST(1,2,3,5));
      v_low_values_in_byte(24) := get_bmap_node_list(INT_LIST(4,5));
      v_low_values_in_byte(25) := get_bmap_node_list(INT_LIST(1,4,5));
      v_low_values_in_byte(26) := get_bmap_node_list(INT_LIST(2,4,5));
      v_low_values_in_byte(27) := get_bmap_node_list(INT_LIST(1,2,4,5));
      v_low_values_in_byte(28) := get_bmap_node_list(INT_LIST(3,4,5));
      v_low_values_in_byte(29) := get_bmap_node_list(INT_LIST(1,3,4,5));
      v_low_values_in_byte(30) := get_bmap_node_list(INT_LIST(2,3,4,5));
      v_low_values_in_byte(31) := get_bmap_node_list(INT_LIST(1,2,3,4,5));
      v_low_values_in_byte(32) := get_bmap_node_list(INT_LIST());
      FOR h IN 1 .. v_low_values_in_byte.COUNT LOOP
        v_high_values_in_byte(h) := v_low_values_in_byte(h);
        FOR x IN 1 .. v_high_values_in_byte( h ).COUNT LOOP
          v_high_values_in_byte( h )( x ) := v_high_values_in_byte( h )( x ) + 5;
        END LOOP;
      END LOOP;
      FOR h IN 1 .. v_high_values_in_byte.COUNT LOOP
        FOR l IN 1 .. v_low_values_in_byte.COUNT LOOP
          idx := MOD( h, 32 )*32 + MOD( l, 32 );
          IF idx > 0 THEN
            v_result( idx ) := multiset_union_all( v_low_values_in_byte( l ), v_high_values_in_byte( h ) );
          END IF;
        END LOOP;
      END LOOP;
      RETURN v_result;
    END init_bit_values_in_byte;

END bmap_segment_builder;
/

SHOW ERRORS
/
