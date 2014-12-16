ALTER SESSION SET PLSQL_WARNINGS='ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE=NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL=3;
/

CREATE OR REPLACE PACKAGE BODY bmap_persist AS

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

  FUNCTION insertBitmapLst (
    pt_bitmap_list BMAP_LEVEL_LIST
  ) RETURN INTEGER
  IS
    bitmap_key INTEGER;
  BEGIN
    IF pt_bitmap_list IS EMPTY or pt_bitmap_list IS NULL THEN
      bitmap_key := 0;
    ELSE
      INSERT INTO hierarchical_bitmap_table VALUES(hierarchical_bitmap_key.nextval, anydata.ConvertCollection(pt_bitmap_list))
      RETURNING bitmap_key INTO bitmap_key;
    END IF;

    RETURN bitmap_key;
  END insertBitmapLst;

  FUNCTION getBitmapLst (
    pi_bitmap_key INTEGER
  ) RETURN BMAP_LEVEL_LIST
  IS
    bmap_lst BMAP_LEVEL_LIST;
    bmap_anydata ANYDATA;
    is_ok pls_integer;
  BEGIN
    IF pi_bitmap_key IS NOT NULL THEN
      BEGIN
        SELECT bmap
          INTO bmap_anydata
          FROM hierarchical_bitmap_table t
         WHERE t.bitmap_key = pi_bitmap_key;

        is_ok := anydata.getCollection(bmap_anydata, bmap_lst);
      EXCEPTION WHEN NO_DATA_FOUND
                THEN bmap_lst := NULL;
      END;
    ELSE
      bmap_lst := NULL;
    END IF;

    RETURN bmap_lst;
  END getBitmapLst;

  FUNCTION updateBitmapLst (
    pi_bitmap_key INTEGER,
    pt_bitmap_list BMAP_LEVEL_LIST
  ) RETURN INTEGER
  IS
    result INTEGER;
  BEGIN
    IF pt_bitmap_list IS NULL OR pt_bitmap_list IS EMPTY THEN
      result := -1;
    ELSE
      UPDATE hierarchical_bitmap_table
         SET bmap = anydata.convertcollection(pt_bitmap_list)
       WHERE bitmap_key = pi_bitmap_key;
      result := sql%rowcount;
    END IF;

    RETURN result;
  END updateBitmapLst;

  FUNCTION deleteBitmapLst (
    pi_bitmap_key INTEGER
  ) RETURN INTEGER
  IS
    result INTEGER;
  BEGIN
    IF pi_bitmap_key IS NULL THEN
      result := 0;
    ELSE
      DELETE
        FROM hierarchical_bitmap_table
       WHERE bitmap_key = pi_bitmap_key;
      result := sql%rowcount;
    END IF;

    RETURN result;
  END deleteBitmapLst;

  PROCEDURE setBitmapLst (
    pi_bitmap_key IN OUT INTEGER,
    pt_bitmap_list BMAP_LEVEL_LIST,
    pio_affected_rows OUT INTEGER
  )
  IS
  BEGIN
    IF pi_bitmap_key IS NULL THEN
      pi_bitmap_key := insertBitmapLst(pt_bitmap_list);
    ELSE
      pio_affected_rows := updateBitmapLst(pi_bitmap_key, pt_bitmap_list);
      IF pio_affected_rows = -1 THEN
        pio_affected_rows := deleteBitmapLst(pi_bitmap_key);
      END IF;
    END IF;
  END setBitmapLst;

  FUNCTION get_index_length RETURN INTEGER IS
  BEGIN
    RETURN C_INDEX_LENGTH;
  END;

END bmap_persist;
/

ALTER PACKAGE bmap_persist COMPILE DEBUG BODY;
/

SHOW ERRORS
/
