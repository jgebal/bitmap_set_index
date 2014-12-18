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
          node_value := BITAND(
              pt_bmap_left( pt_level )( pt_compare_lst( i ) ),
              pt_bmap_right( pt_level )( pt_compare_lst( i ) )
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
    exception when others then null;
    END bit_and_on_level;

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

END bmap_operator;
/

SHOW ERRORS
/
