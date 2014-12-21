ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/
CREATE OR REPLACE PACKAGE BODY bmap_operator AS

  PROCEDURE bit_and_on_level(
    pt_bmap_left   IN            BMAP_LEVEL_LIST,
    pt_bmap_right  IN            BMAP_LEVEL_LIST,
    pt_level       IN            BINARY_INTEGER,
    pt_compare_lst IN            INT_LIST,
    pt_bmap_result IN OUT NOCOPY BMAP_LEVEL_LIST
  );

  FUNCTION bitor(
    p_left IN BINARY_INTEGER,
    p_right IN BINARY_INTEGER
  ) RETURN BINARY_INTEGER DETERMINISTIC IS
  BEGIN
    RETURN p_left + (p_right - BITAND(p_left, p_right));
  END bitor;

  FUNCTION get_val_from_lst(
    p_val_lst IN BMAP_NODE_LIST,
    p_pos     IN BINARY_INTEGER) RETURN BINARY_INTEGER DETERMINISTIC IS
    BEGIN
      RETURN p_val_lst(p_pos);
      EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN 0;
    END;

  PROCEDURE bit_and_on_level(
    pt_bmap_left   IN            BMAP_LEVEL_LIST,
    pt_bmap_right  IN            BMAP_LEVEL_LIST,
    pt_level       IN            BINARY_INTEGER,
    pt_compare_lst IN            INT_LIST,
    pt_bmap_result IN OUT NOCOPY BMAP_LEVEL_LIST
  ) IS
    node_value BINARY_INTEGER;
    BEGIN
      IF pt_level > 0 THEN
        FOR i IN 1 .. CARDINALITY( pt_compare_lst ) LOOP
          PRAGMA INLINE (get_val_from_lst, 'YES');
          node_value := BITAND(
              get_val_from_lst(pt_bmap_left( pt_level ), pt_compare_lst( i ) ),
              get_val_from_lst(pt_bmap_right( pt_level ), pt_compare_lst( i ) )
          );
          IF node_value > 0 THEN
            pt_bmap_result( pt_level )( pt_compare_lst( i ) ) := node_value;
          END IF;
        END LOOP;
        bit_and_on_level(
            pt_bmap_left,
            pt_bmap_right,
            pt_level - 1,
            bmap_builder.decode_bitmap_level( pt_bmap_result( pt_level ) ),
            pt_bmap_result );
      END IF;
    END bit_and_on_level;

  PROCEDURE bit_or_on_level(
    pt_bmap_left   IN            BMAP_LEVEL_LIST,
    pt_bmap_right  IN            BMAP_LEVEL_LIST,
    pt_level       IN            BINARY_INTEGER,
    pt_compare_lst IN            INT_LIST,
    pt_bmap_result IN OUT NOCOPY BMAP_LEVEL_LIST
  ) IS
    node_value  BINARY_INTEGER;
    v_left_val  BINARY_INTEGER;
    v_right_val BINARY_INTEGER;
    BEGIN
      IF pt_level > 0 THEN
        FOR i IN 1 .. CARDINALITY( pt_compare_lst ) LOOP
          BEGIN
            PRAGMA INLINE (get_val_from_lst, 'YES');
            v_left_val := get_val_from_lst( pt_bmap_left( pt_level ), pt_compare_lst( i ) );
            PRAGMA INLINE (get_val_from_lst, 'YES');
            v_right_val := get_val_from_lst( pt_bmap_right( pt_level ), pt_compare_lst( i ) );
            PRAGMA INLINE (bitor, 'YES');
            node_value := bitor( v_left_val, v_right_val );
            IF node_value > 0 THEN
              pt_bmap_result( pt_level )( pt_compare_lst( i ) ) := node_value;
            END IF;
          END;
        END LOOP;
        bit_or_on_level(
            pt_bmap_left,
            pt_bmap_right,
            pt_level - 1,
            bmap_builder.decode_bitmap_level( pt_bmap_result( pt_level ) ),
            pt_bmap_result );
      END IF;
    END bit_or_on_level;

  FUNCTION bit_and(
    pt_bmap_left  IN BMAP_LEVEL_LIST,
    pt_bmap_right IN BMAP_LEVEL_LIST
  ) RETURN BMAP_LEVEL_LIST IS
    result_bmap   BMAP_LEVEL_LIST := BMAP_LEVEL_LIST( );
    bitmap_height BINARY_INTEGER;
    BEGIN
      IF pt_bmap_left IS NULL OR pt_bmap_right IS NULL OR pt_bmap_left IS EMPTY OR
         pt_bmap_right IS EMPTY THEN
        RETURN result_bmap;
      END IF;
      bmap_builder.init( result_bmap );
      bit_and_on_level(
          pt_bmap_left,
          pt_bmap_right,
          bmap_builder.C_INDEX_DEPTH,
          INT_LIST( 1 ),
          result_bmap );
      RETURN result_bmap;
    END bit_and;

  FUNCTION bit_or(
    pt_bmap_left  IN BMAP_LEVEL_LIST,
    pt_bmap_right IN BMAP_LEVEL_LIST
  ) RETURN BMAP_LEVEL_LIST IS
    result_bmap   BMAP_LEVEL_LIST := BMAP_LEVEL_LIST( );
    bitmap_height BINARY_INTEGER;
    BEGIN
      IF pt_bmap_left IS NULL OR pt_bmap_right IS NULL OR pt_bmap_left IS EMPTY OR
         pt_bmap_right IS EMPTY THEN
        RETURN result_bmap;
      END IF;
      bmap_builder.init( result_bmap );
      bit_or_on_level(
          pt_bmap_left,
          pt_bmap_right,
          bmap_builder.C_INDEX_DEPTH,
          INT_LIST( 1 ),
          result_bmap );
      RETURN result_bmap;
    END bit_or;


END bmap_operator;
/

SHOW ERRORS
/
