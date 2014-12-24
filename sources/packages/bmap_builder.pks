ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE bmap_builder AS

  C_INDEX_LENGTH CONSTANT BINARY_INTEGER := 30;
  C_INDEX_DEPTH CONSTANT BINARY_INTEGER := 5;
  C_MAX_BITS CONSTANT NUMBER := POWER( C_INDEX_LENGTH, C_INDEX_DEPTH );

  FUNCTION init_bit_values_in_byte RETURN BMAP_LEVEL_LIST;


  FUNCTION encode_bitmap(
    pt_bit_numbers_list INT_LIST
  ) RETURN BMAP_LEVEL_LIST;

  FUNCTION decode_bitmap(
    pt_bitmap_tree BMAP_LEVEL_LIST
  ) RETURN INT_LIST;

  FUNCTION bit_and(
    pt_bmap_left  IN BMAP_LEVEL_LIST,
    pt_bmap_right IN BMAP_LEVEL_LIST
  ) RETURN BMAP_LEVEL_LIST;

  FUNCTION bit_or(
    pt_bmap_left  IN BMAP_LEVEL_LIST,
    pt_bmap_right IN BMAP_LEVEL_LIST
  ) RETURN BMAP_LEVEL_LIST;

  FUNCTION bit_minus(
    pt_bmap_left  IN BMAP_LEVEL_LIST,
    pt_bmap_right IN BMAP_LEVEL_LIST
  ) RETURN BMAP_LEVEL_LIST;

  PROCEDURE add_bit_list_to_bitmap(
    pt_bit_numbers_list INT_LIST,
    pt_bit_map_tree   IN OUT NOCOPY BMAP_LEVEL_LIST
  );

  FUNCTION get_index_length RETURN INTEGER;

  PROCEDURE init( pt_bitmap_tree IN OUT NOCOPY BMAP_LEVEL_LIST );

  FUNCTION decode_bitmap_level(
    pt_bitmap_node_list BMAP_NODE_LIST
  ) RETURN INT_LIST;

END bmap_builder;
/

SHOW ERRORS
/
