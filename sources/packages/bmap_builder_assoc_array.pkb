ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE BODY bmap_builder AS

--PRIVATE SPECIFICATIONS

  ge_subscript_beyond_count EXCEPTION;
  PRAGMA EXCEPTION_INIT(ge_subscript_beyond_count,-6533);

  gc_bit_values_in_byte    CONSTANT BMAP_LEVEL_LIST := init_bit_values_in_byte();

  PROCEDURE bit_and_on_level(
    pt_bmap_left   IN            BMAP_LEVEL_LIST,
    pt_bmap_right  IN            BMAP_LEVEL_LIST,
    p_level        IN            PLS_INTEGER,
    p_node         IN            PLS_INTEGER,
    pt_bmap_result IN OUT NOCOPY BMAP_LEVEL_LIST
  );

  PROCEDURE bit_or_on_level(
    pt_bmap_left   IN            BMAP_LEVEL_LIST,
    pt_bmap_right  IN            BMAP_LEVEL_LIST,
    p_level        IN            PLS_INTEGER,
    p_node         IN            PLS_INTEGER,
    pt_bmap_result IN OUT NOCOPY BMAP_LEVEL_LIST
  );

  PROCEDURE bit_minus_on_level(
    pt_bmap_left   IN OUT NOCOPY BMAP_LEVEL_LIST,
    pt_bmap_right  IN            BMAP_LEVEL_LIST,
    p_level        IN            PLS_INTEGER,
    p_node         IN            PLS_INTEGER
  );

  FUNCTION get_val_from_lst(
    p_val_lst IN BMAP_NODE_LIST,
    p_pos     IN PLS_INTEGER
  ) RETURN PLS_INTEGER DETERMINISTIC;

--IMPLEMENTATIONS

  PROCEDURE init( pt_bitmap_tree IN OUT NOCOPY BMAP_LEVEL_LIST ) IS
    x BMAP_NODE_LIST;
    BEGIN
      FOR i IN 1 .. C_INDEX_DEPTH LOOP
        pt_bitmap_tree( i ) := x;
      END LOOP;
    END init;

  FUNCTION bitor(
    p_left IN BINARY_INTEGER,
    p_right IN BINARY_INTEGER
  ) RETURN BINARY_INTEGER DETERMINISTIC IS
    BEGIN
      RETURN p_left + (p_right - BITAND(p_left, p_right));
    END bitor;

  FUNCTION get_val_from_lst(
    p_val_lst IN BMAP_NODE_LIST,
    p_pos     IN PLS_INTEGER
  ) RETURN PLS_INTEGER DETERMINISTIC IS
    BEGIN
      RETURN p_val_lst(p_pos);
      EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN 0;
    END get_val_from_lst;

  FUNCTION deduplicate_bit_numbers_list(
    pt_bit_numbers_list int_list
  ) RETURN INT_LIST IS
    bit_no_set INT_LIST := INT_LIST( );
    BEGIN
      SELECT
        DISTINCT
        COLUMN_VALUE
      BULK COLLECT INTO bit_no_set
      FROM TABLE (pt_bit_numbers_list)
      WHERE COLUMN_VALUE IS NOT NULL
      ORDER BY 1;

      RETURN bit_no_set;
    END deduplicate_bit_numbers_list;

  PROCEDURE assign_bit_in_segment(
    pt_bitmap_tree_level IN OUT NOCOPY BMAP_NODE_LIST,
    pi_bit_number        IN            BINARY_INTEGER
  ) IS
    bit_number_in_segment INTEGER := 0;
    segment_number        BINARY_INTEGER := 0;
    BEGIN
      bit_number_in_segment := MOD( pi_bit_number - 1, C_INDEX_LENGTH );
      segment_number := CEIL( pi_bit_number / C_INDEX_LENGTH );
      IF NOT pt_bitmap_tree_level.EXISTS( segment_number ) THEN
        pt_bitmap_tree_level( segment_number ) := POWER( 2, bit_number_in_segment );
      ELSE
        PRAGMA INLINE (bitor, 'YES');
        pt_bitmap_tree_level( segment_number ) := bitor( pt_bitmap_tree_level( segment_number ), POWER( 2, bit_number_in_segment ) );
      END IF;
    END assign_bit_in_segment;

  PROCEDURE build_leaf_level(
    pt_bitmap_node     IN OUT NOCOPY BMAP_NODE_LIST,
    pt_bit_numbers_set IN            INT_LIST
  ) IS
    bit_number_idx INTEGER;
    BEGIN
      bit_number_idx := pt_bit_numbers_set.FIRST;
      LOOP
        EXIT WHEN bit_number_idx IS NULL;
        assign_bit_in_segment( pt_bitmap_node, pt_bit_numbers_set( bit_number_idx ) );
        bit_number_idx := pt_bit_numbers_set.NEXT( bit_number_idx );
      END LOOP;
    END build_leaf_level;

  PROCEDURE build_level(
    pt_bitmap_tree          IN OUT NOCOPY BMAP_LEVEL_LIST,
    pi_bit_map_level_number IN            BINARY_INTEGER
  ) IS
    node INTEGER;
    BEGIN
      node := pt_bitmap_tree( pi_bit_map_level_number - 1 ).FIRST;
      LOOP
        EXIT WHEN node IS NULL;
        assign_bit_in_segment( pt_bitmap_tree( pi_bit_map_level_number ), node );
        node := pt_bitmap_tree( pi_bit_map_level_number - 1 ).NEXT( node );
      END LOOP;
    END build_level;

  PROCEDURE add_bit_list_to_bitmap(
    pt_bit_numbers_list INT_LIST,
    pt_bit_map_tree   IN OUT NOCOPY BMAP_LEVEL_LIST
  ) IS
    bit_numbers_set INT_LIST := INT_LIST( );
    v_bitmap_node   BMAP_NODE_LIST;
    max_bit_number  NUMBER;
    BEGIN
      IF pt_bit_numbers_list IS NULL OR CARDINALITY( pt_bit_numbers_list ) = 0 THEN
        RETURN;
      END IF;

      SELECT
        MAX( COLUMN_VALUE ) INTO max_bit_number
      FROM TABLE (pt_bit_numbers_list);
      IF max_bit_number > C_MAX_BITS THEN
        RAISE_APPLICATION_ERROR( -20000, 'Index size overflow' );
      END IF;

      bit_numbers_set := deduplicate_bit_numbers_list( pt_bit_numbers_list );

      IF bit_numbers_set.COUNT = 0 THEN
        RETURN;
      END IF;

      IF pt_bit_map_tree IS NULL OR pt_bit_map_tree.COUNT = 0 THEN
        init( pt_bit_map_tree );
      END IF;

      build_leaf_level( v_bitmap_node, bit_numbers_set );
      pt_bit_map_tree( 1 ) := v_bitmap_node;
      FOR bit_map_level_number IN 2 .. C_INDEX_DEPTH LOOP
        build_level( pt_bit_map_tree, bit_map_level_number );
      END LOOP;

    END add_bit_list_to_bitmap;

  FUNCTION encode_bitmap(
    pt_bit_numbers_list INT_LIST
  ) RETURN BMAP_LEVEL_LIST IS
    bit_map_tree    BMAP_LEVEL_LIST;
    BEGIN
      add_bit_list_to_bitmap(pt_bit_numbers_list, bit_map_tree);
      RETURN bit_map_tree;
    END encode_bitmap;

  FUNCTION decode_bitmap(
    pt_bitmap_tree BMAP_LEVEL_LIST
  ) RETURN INT_LIST IS
    BEGIN
      IF pt_bitmap_tree IS NULL OR pt_bitmap_tree.COUNT = 0 THEN
        RETURN INT_LIST( );
      END IF;

      RETURN decode_bitmap_level( pt_bitmap_tree(1) );
    END decode_bitmap;

  FUNCTION decode_bitmap_node(
    p_node_value PLS_INTEGER
  ) RETURN PLS_INT_LIST IS
    bit_numbers_list PLS_INT_LIST := PLS_INT_LIST( );
    byte_values_list BMAP_NODE_LIST;
    remaining_value  PLS_INTEGER;
    bit_pos          PLS_INTEGER := 0;
    byte_values_idx  PLS_INTEGER;
    BEGIN
      remaining_value := p_node_value;
      WHILE remaining_value != 0 LOOP
        byte_values_idx := MOD( remaining_value, 1024 );
        IF byte_values_idx > 0 THEN
          byte_values_list := gc_bit_values_in_byte( byte_values_idx );
          FOR i IN byte_values_list.FIRST .. byte_values_list.LAST LOOP
            bit_numbers_list.EXTEND;
            bit_numbers_list( bit_numbers_list.LAST ) := byte_values_list(i)+bit_pos;
          END LOOP;
        END IF;
        remaining_value := FLOOR(remaining_value / 1024);
        bit_pos := bit_pos + 10;
      END LOOP;
      RETURN bit_numbers_list;
    END decode_bitmap_node;

  FUNCTION decode_bitmap_level(
    pt_bitmap_node_list BMAP_NODE_LIST
  ) RETURN INT_LIST IS
    bit_numbers_list INT_LIST := INT_LIST( );
    byte_values_list PLS_INT_LIST;
    node_number      PLS_INTEGER;
    remaining_value  PLS_INTEGER;
    bit_pos          PLS_INTEGER;
    byte_values_idx  PLS_INTEGER;
    BEGIN
      node_number := pt_bitmap_node_list.FIRST;
      LOOP
        EXIT WHEN node_number IS NULL;
        bit_pos := C_INDEX_LENGTH * ( node_number - 1 );

        byte_values_list := decode_bitmap_node( pt_bitmap_node_list( node_number ) );
        FOR i IN 1 .. byte_values_list.COUNT LOOP
          bit_numbers_list.EXTEND;
          bit_numbers_list( bit_numbers_list.LAST ) := byte_values_list(i) + bit_pos;
        END LOOP;
        node_number := pt_bitmap_node_list.NEXT( node_number );
      END LOOP;
      RETURN bit_numbers_list;
    END decode_bitmap_level;

  PROCEDURE bit_and_on_level(
    pt_bmap_left   IN            BMAP_LEVEL_LIST,
    pt_bmap_right  IN            BMAP_LEVEL_LIST,
    p_level        IN            PLS_INTEGER,
    p_node         IN            PLS_INTEGER,
    pt_bmap_result IN OUT NOCOPY BMAP_LEVEL_LIST
  ) IS
    node_value        PLS_INTEGER;
    v_child_node_list PLS_INT_LIST;
    BEGIN
      node_value := BITAND( pt_bmap_left( p_level )( p_node ), pt_bmap_right( p_level )( p_node ) );
      IF node_value > 0 THEN
        pt_bmap_result( p_level )( p_node ) := node_value;
        IF p_level - 1 > 0 THEN
          v_child_node_list := decode_bitmap_node( node_value );
          FOR i IN 1 .. CARDINALITY( v_child_node_list ) LOOP
          bit_and_on_level(
              pt_bmap_left,
              pt_bmap_right,
              p_level - 1,
              v_child_node_list(i) + C_INDEX_LENGTH * ( p_node - 1 ),
              pt_bmap_result
          );
          END LOOP;
        END IF;
      END IF;
    END bit_and_on_level;

  PROCEDURE bit_or_on_level(
    pt_bmap_left   IN            BMAP_LEVEL_LIST,
    pt_bmap_right  IN            BMAP_LEVEL_LIST,
    p_level        IN            PLS_INTEGER,
    p_node         IN            PLS_INTEGER,
    pt_bmap_result IN OUT NOCOPY BMAP_LEVEL_LIST
  ) IS
    node_value        PLS_INTEGER;
    v_child_node_list PLS_INT_LIST;
    BEGIN
      IF NOT pt_bmap_left( p_level ).EXISTS( p_node ) THEN
        node_value := pt_bmap_right( p_level )( p_node );
      ELSIF NOT pt_bmap_right( p_level ).EXISTS( p_node ) THEN
        node_value := pt_bmap_left( p_level )( p_node );
      ELSE
        PRAGMA INLINE (bitor, 'YES');
        node_value := bitor( pt_bmap_left( p_level )( p_node ), pt_bmap_right( p_level )( p_node ) );
      END IF;
      IF node_value > 0 THEN
        pt_bmap_result( p_level )( p_node ) := node_value;
        IF p_level -1 > 0 THEN
          v_child_node_list := decode_bitmap_node( node_value );
          FOR i IN 1 .. CARDINALITY( v_child_node_list ) LOOP
            bit_or_on_level(
                pt_bmap_left,
                pt_bmap_right,
                p_level - 1,
                v_child_node_list(i) + C_INDEX_LENGTH * ( p_node - 1 ),
                pt_bmap_result
            );
          END LOOP;
        END IF;
      END IF;
    END bit_or_on_level;

  PROCEDURE bit_minus_on_level(
    pt_bmap_left   IN OUT NOCOPY BMAP_LEVEL_LIST,
    pt_bmap_right  IN            BMAP_LEVEL_LIST,
    p_level        IN            PLS_INTEGER,
    p_node         IN            PLS_INTEGER
  ) IS
    node_value        PLS_INTEGER;
    v_child_node_list PLS_INT_LIST;
    i                 PLS_INTEGER;
    BEGIN
      node_value := pt_bmap_left( p_level )( p_node ) - BITAND( pt_bmap_left( p_level )( p_node ), pt_bmap_right( p_level )( p_node ) );
      IF p_level - 1 > 0 THEN
        v_child_node_list := decode_bitmap_node( pt_bmap_left( p_level )( p_node ) );
        FOR i IN 1 .. CARDINALITY( v_child_node_list ) LOOP
          bit_minus_on_level(
              pt_bmap_left,
              pt_bmap_right,
              p_level - 1,
              v_child_node_list(i) + C_INDEX_LENGTH * ( p_node - 1 )
          );
        END LOOP;
      END IF;
      IF node_value > 0 THEN
        pt_bmap_left( p_level )( p_node ) := node_value;
      ELSE
        pt_bmap_left( p_level ).DELETE( p_node );
      END IF;
    EXCEPTION WHEN NO_DATA_FOUND OR ge_subscript_beyond_count THEN
      NULL;
    END bit_minus_on_level;

  FUNCTION bit_and(
    pt_bmap_left  IN BMAP_LEVEL_LIST,
    pt_bmap_right IN BMAP_LEVEL_LIST
  ) RETURN BMAP_LEVEL_LIST IS
    result_bmap   BMAP_LEVEL_LIST;
    bitmap_height BINARY_INTEGER;
    BEGIN
      IF pt_bmap_left IS NULL OR pt_bmap_right IS NULL OR pt_bmap_left.COUNT = 0 OR
         pt_bmap_right.COUNT = 0 THEN
        RETURN result_bmap;
      END IF;
      init( result_bmap );
      bit_and_on_level(
          pt_bmap_left,
          pt_bmap_right,
          C_INDEX_DEPTH,
          1,
          result_bmap );
      RETURN result_bmap;
    END bit_and;

  FUNCTION bit_or(
    pt_bmap_left  IN BMAP_LEVEL_LIST,
    pt_bmap_right IN BMAP_LEVEL_LIST
  ) RETURN BMAP_LEVEL_LIST IS
    result_bmap   BMAP_LEVEL_LIST;
    bitmap_height BINARY_INTEGER;
    BEGIN
      IF pt_bmap_left IS NULL OR pt_bmap_right IS NULL OR pt_bmap_left.COUNT = 0 OR
         pt_bmap_right.COUNT = 0 THEN
        RETURN result_bmap;
      END IF;
      init( result_bmap );
      bit_or_on_level(
          pt_bmap_left,
          pt_bmap_right,
          C_INDEX_DEPTH,
          1,
          result_bmap );
      RETURN result_bmap;
    END bit_or;

  FUNCTION bit_minus(
    pt_bmap_left  IN BMAP_LEVEL_LIST,
    pt_bmap_right IN BMAP_LEVEL_LIST
  ) RETURN BMAP_LEVEL_LIST IS
    result_bmap   BMAP_LEVEL_LIST := pt_bmap_left;
    bitmap_height BINARY_INTEGER;
    BEGIN
      IF pt_bmap_left IS NULL OR pt_bmap_right IS NULL OR pt_bmap_left.COUNT = 0 OR
         pt_bmap_right.COUNT = 0 THEN
        RETURN result_bmap;
      END IF;
      bit_minus_on_level( result_bmap, pt_bmap_right, C_INDEX_DEPTH, 1 );
      RETURN result_bmap;
    END bit_minus;


  FUNCTION get_index_length RETURN INTEGER IS
    BEGIN
      RETURN C_INDEX_LENGTH;
    END;

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
  FUNCTION init_bit_values_in_byte RETURN BMAP_LEVEL_LIST
  IS
    v_low_values_in_byte  BMAP_LEVEL_LIST;
    v_high_values_in_byte BMAP_LEVEL_LIST;
    v_result              BMAP_LEVEL_LIST;
    idx                   BINARY_INTEGER;
    FUNCTION get_bmap_node_list(p_lst int_list) RETURN BMAP_NODE_LIST IS
      v_res BMAP_NODE_LIST;
      BEGIN
        FOR i IN 1 .. p_lst.COUNT loop
          v_res(i) := p_lst(i);
        END LOOP;
        RETURN v_res;
      END get_bmap_node_list;
    FUNCTION multiset_union_all(p_left BMAP_NODE_LIST, p_right BMAP_NODE_LIST) RETURN BMAP_NODE_LIST IS
      v_res BMAP_NODE_LIST;
      i PLS_INTEGER;
      j PLS_INTEGER := 0;
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
--       v_low_values_in_byte.EXTEND(32);
--       v_high_values_in_byte.EXTEND(32);
--       v_result.EXTEND(1023);
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

END bmap_builder;
/

SHOW ERRORS
/
