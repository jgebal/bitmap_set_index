ALTER SESSION SET PLSQL_WARNINGS='ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE=NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL=3;
/

CREATE OR REPLACE PACKAGE BODY bmap_builder AS

  PROCEDURE init(pt_bitmap_tree IN OUT NOCOPY BMAP_LEVEL_LIST) IS
    BEGIN
      pt_bitmap_tree := BMAP_LEVEL_LIST();
      pt_bitmap_tree.EXTEND(C_INDEX_DEPTH);
      FOR i IN 1 .. C_INDEX_DEPTH LOOP
        pt_bitmap_tree(i) := BMAP_NODE_LIST();
        pt_bitmap_tree(i).EXTEND( CEIL(C_MAX_BITS/POWER(C_INDEX_LENGTH,i)) );
        pt_bitmap_tree(i).DELETE(1, CEIL(C_MAX_BITS/POWER(C_INDEX_LENGTH,i)) );
      END LOOP;
    END init;

  FUNCTION deduplicate_bit_numbers_list(
    pt_bit_numbers_list int_list
  ) RETURN int_list IS
    bit_no_set     int_list := int_list();
    BEGIN
      SELECT DISTINCT COLUMN_VALUE
      BULK COLLECT INTO bit_no_set
      FROM TABLE(pt_bit_numbers_list)
      WHERE COLUMN_VALUE IS NOT NULL
      ORDER BY 1;

      RETURN bit_no_set;
    END deduplicate_bit_numbers_list;

  PROCEDURE assign_bit_in_segment(
    pt_bitmap_tree_level IN OUT NOCOPY BMAP_NODE_LIST,
    pi_bit_number IN SIMPLE_INTEGER
  ) IS
    bit_number_in_segment INTEGER := 0;
    segment_number        SIMPLE_INTEGER := 0;
    BEGIN
      bit_number_in_segment := MOD( pi_bit_number - 1, C_INDEX_LENGTH );
      segment_number        := CEIL( pi_bit_number / C_INDEX_LENGTH );
      IF NOT pt_bitmap_tree_level.EXISTS(segment_number) THEN
        pt_bitmap_tree_level(segment_number) := POWER( 2, bit_number_in_segment );
      ELSE
        pt_bitmap_tree_level(segment_number) := pt_bitmap_tree_level(segment_number) + POWER(2, bit_number_in_segment );
      END IF;
    END assign_bit_in_segment;

  PROCEDURE build_leaf_level(
    pt_bitmap_node IN OUT NOCOPY BMAP_NODE_LIST,
    pt_bit_numbers_set IN INT_LIST
  ) IS
    bit_number_idx INTEGER;
    BEGIN
      bit_number_idx := pt_bit_numbers_set.FIRST;
      LOOP
        EXIT WHEN bit_number_idx IS NULL;
        assign_bit_in_segment(pt_bitmap_node, pt_bit_numbers_set(bit_number_idx) );
        bit_number_idx := pt_bit_numbers_set.NEXT(bit_number_idx);
      END LOOP;
    END build_leaf_level;

  PROCEDURE build_level(
    pt_bitmap_tree IN OUT NOCOPY BMAP_LEVEL_LIST,
    pi_bit_map_level_number IN SIMPLE_INTEGER
  ) IS
    node INTEGER;
    BEGIN
      node := pt_bitmap_tree(pi_bit_map_level_number - 1).FIRST ;
      LOOP
        EXIT WHEN node IS NULL;
        assign_bit_in_segment( pt_bitmap_tree(pi_bit_map_level_number), node );
        node := pt_bitmap_tree(pi_bit_map_level_number - 1).NEXT(node);
      END LOOP;
    END build_level;


  FUNCTION bit_no_lst_to_bit_map(
    pt_bit_numbers_list INT_LIST
  ) RETURN BMAP_LEVEL_LIST IS
    bit_numbers_set INT_LIST := INT_LIST();
    bit_map_tree    BMAP_LEVEL_LIST := BMAP_LEVEL_LIST();
    max_bit_number  NUMBER;
    BEGIN
      IF pt_bit_numbers_list IS NULL OR CARDINALITY(pt_bit_numbers_list) = 0 THEN
        RETURN bit_map_tree;
      END IF;

      SELECT MAX(COLUMN_VALUE) INTO max_bit_number FROM TABLE(pt_bit_numbers_list);
      IF max_bit_number > C_MAX_BITS THEN
        RAISE_APPLICATION_ERROR(-20000, 'Index size overflow');
      END IF;

      bit_numbers_set := deduplicate_bit_numbers_list(pt_bit_numbers_list);

      IF bit_numbers_set.COUNT = 0 THEN
        RETURN bit_map_tree;
      END IF;

      init(bit_map_tree);

      build_leaf_level( bit_map_tree(1), bit_numbers_set);
      FOR bit_map_level_number IN 2 .. C_INDEX_DEPTH LOOP
        build_level( bit_map_tree, bit_map_level_number);
      END LOOP;

      RETURN bit_map_tree;
    END bit_no_lst_to_bit_map;

  FUNCTION get_index_length RETURN INTEGER IS
    BEGIN
      RETURN C_INDEX_LENGTH;
    END;

END bmap_builder;
/

ALTER PACKAGE bmap_builder COMPILE DEBUG BODY;
/

SHOW ERRORS
/
