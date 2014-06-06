CREATE OR REPLACE PACKAGE BODY BMAP_UTIL AS

  E_SUBSCRIPT_BEYOND_COUNT EXCEPTION;
  PRAGMA EXCEPTION_INIT( E_SUBSCRIPT_BEYOND_COUNT, -6533 );

  FUNCTION deduplicate_bit_numbers_list(p_bit_numbers_list int_list) RETURN int_list IS
    bit_no_set     int_list := int_list();
    BEGIN
      SELECT DISTINCT COLUMN_VALUE
      BULK COLLECT INTO bit_no_set
      FROM TABLE(p_bit_numbers_list)
      WHERE COLUMN_VALUE IS NOT NULL
      ORDER BY 1 DESC;

      RETURN bit_no_set;
    END;

  PROCEDURE assign_bit_in_segment(bit_map_tree_level IN OUT NOCOPY BMAP_NODE_LIST, segment_number IN SIMPLE_INTEGER, bit_number IN SIMPLE_INTEGER) IS
    BEGIN
      IF NOT bit_map_tree_level.EXISTS(segment_number) THEN
        bit_map_tree_level.EXTEND(segment_number - bit_map_tree_level.LAST);
        bit_map_tree_level(segment_number) := POWER(2,bit_number);
      ELSE
        bit_map_tree_level(segment_number) := bit_map_tree_level(segment_number) + POWER(2,bit_number);
      END IF;
    END;

  PROCEDURE build_leaf_level(bit_map_leaves IN OUT NOCOPY BMAP_NODE_LIST, bit_numbers_set IN INT_LIST) IS
    bit_number     INTEGER := 0;
    segment_number SIMPLE_INTEGER := 0;
    BEGIN
      FOR idx IN bit_numbers_set.FIRST .. bit_numbers_set.LAST LOOP
        bit_number :=     MOD( bit_numbers_set(idx) - 1, C_INDEX_LENGTH );
        segment_number := CEIL( bit_numbers_set(idx) / C_INDEX_LENGTH );
        assign_bit_in_segment(bit_map_leaves, segment_number, bit_number);
      END LOOP;
    END build_leaf_level;

  PROCEDURE build_level(bit_map_tree IN OUT NOCOPY BMAP_LEVEL_LIST, bit_map_level_number IN SIMPLE_INTEGER, bit_numbers_set IN INT_LIST) IS
    first_node     NUMBER;
    last_node      NUMBER;
    bit_number     INTEGER := 0;
    segment_number SIMPLE_INTEGER := 0;
    BEGIN
      first_node := CEIL( bit_map_tree(bit_map_level_number - 1).FIRST / C_INDEX_LENGTH);
      last_node := CEIL( bit_map_tree(bit_map_level_number - 1).LAST / C_INDEX_LENGTH);
      FOR node IN first_node .. last_node LOOP
        IF bit_map_tree(bit_map_level_number - 1)(node) IS NULL THEN
          CONTINUE;
        END IF;
        bit_number := MOD(node - 1, C_INDEX_LENGTH);
        segment_number := CEIL(node / C_INDEX_LENGTH);
        assign_bit_in_segment(bit_map_tree(bit_map_level_number), segment_number, bit_number);
      END LOOP;
    END build_level;

  FUNCTION bit_no_lst_to_bit_map(
    p_bit_numbers_list INT_LIST
  ) RETURN BMAP_LEVEL_LIST IS
    bit_numbers_set INT_LIST := INT_LIST();
    bit_map_tree    BMAP_LEVEL_LIST := BMAP_LEVEL_LIST();
    max_bit_number  NUMBER;
  BEGIN
    IF p_bit_numbers_list IS NULL OR CARDINALITY(p_bit_numbers_list) = 0 THEN
      RETURN bit_map_tree;
    END IF;

    SELECT MAX(COLUMN_VALUE)
    INTO max_bit_number
    FROM TABLE(p_bit_numbers_list);

    IF max_bit_number > C_MAX_BITS THEN
      RAISE_APPLICATION_ERROR(-20000, 'Index size overflow');
    END IF;

    bit_numbers_set := deduplicate_bit_numbers_list(p_bit_numbers_list);

    IF bit_numbers_set.COUNT = 0 THEN
      RETURN bit_map_tree;
    END IF;

    FOR bit_map_level_number IN 1 .. C_INDEX_DEPTH LOOP
      bit_map_tree.extend;
      bit_map_tree( bit_map_level_number ) := BMAP_NODE_LIST(0);
      IF bit_map_level_number = 1 THEN
        build_leaf_level( bit_map_tree(bit_map_level_number), bit_numbers_set);
      ELSE
        build_level(bit_map_tree, bit_map_level_number, bit_numbers_set);
      END IF;
    END LOOP;

    RETURN bit_map_tree;
  END bit_no_lst_to_bit_map;

  FUNCTION bitor(
    left  SIMPLE_INTEGER ,
    right SIMPLE_INTEGER ) RETURN SIMPLE_INTEGER
  IS
  BEGIN
    RETURN left + right - BITAND( left, right );
  END bitor;

  FUNCTION insertBitmapLst (
    pt_bmap_list BMAP_LEVEL_LIST
  ) RETURN INTEGER
  IS
    bitmap_key INTEGER;
  BEGIN
    IF pt_bmap_list IS EMPTY or pt_bmap_list IS NULL THEN
      bitmap_key := 0;
    ELSE
      INSERT INTO hierarchical_bitmap_table VALUES(hierarchical_bitmap_key.nextval, anydata.ConvertCollection(pt_bmap_list))
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
    pt_bmap_list BMAP_LEVEL_LIST
  ) RETURN INTEGER
  IS
    result INTEGER;
  BEGIN
    IF pt_bmap_list IS NULL OR pt_bmap_list IS EMPTY THEN
      result := -1;
    ELSE
      UPDATE hierarchical_bitmap_table
         SET bmap = anydata.convertcollection(pt_bmap_list)
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
    pt_bmap_list BMAP_LEVEL_LIST,
    pio_affected_rows OUT INTEGER
  )
  IS
  BEGIN
    IF pi_bitmap_key IS NULL THEN
      pi_bitmap_key := insertBitmapLst(pt_bmap_list);
    ELSE
      pio_affected_rows := updateBitmapLst(pi_bitmap_key, pt_bmap_list);
      IF pio_affected_rows = -1 THEN
        pio_affected_rows := deleteBitmapLst(pi_bitmap_key);
      END IF;
    END IF;
  END setBitmapLst;
END BMAP_UTIL;
/

ALTER PACKAGE BMAP_UTIL COMPILE DEBUG BODY;
/
