ALTER SESSION SET PLSQL_WARNINGS='ENABLE:ALL';
/

ALTER SESSION SET PLSQL_CODE_TYPE=NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL=3;
/

CREATE OR REPLACE PACKAGE BODY BMAP_UTIL AS

  C_MAX_BITS       CONSTANT NUMBER := POWER(C_INDEX_LENGTH,C_INDEX_DEPTH);

  FUNCTION bit_no_lst_to_bit_map(
    p_bit_no_lst int_list
  ) RETURN BMAP_LEVEL_LIST IS
    p_bit_no_set int_list := int_list();
    bit_map BMAP_LEVEL_LIST := BMAP_LEVEL_LIST();

    bit_no        SIMPLE_INTEGER := 0;
    bit_map_no    SIMPLE_INTEGER := 0;
    max_bit_no    NUMBER;
    first_node    NUMBER;
    last_node     NUMBER;
    E_SUBSCRIPT_BEYOND_COUNT EXCEPTION;
    PRAGMA EXCEPTION_INIT( E_SUBSCRIPT_BEYOND_COUNT, -6533 );
  BEGIN
    IF p_bit_no_lst IS NOT NULL AND CARDINALITY(p_bit_no_lst) != 0 THEN
      SELECT MAX(COLUMN_VALUE)
        INTO max_bit_no
        FROM TABLE(p_bit_no_lst);
      IF max_bit_no > C_MAX_BITS THEN
        RAISE_APPLICATION_ERROR(-20000, 'Index size overflow');
      END IF;
      --deduplicate, remove NULL and sort
      SELECT DISTINCT COLUMN_VALUE
        BULK COLLECT INTO p_bit_no_set
        FROM TABLE(p_bit_no_lst)
       WHERE COLUMN_VALUE IS NOT NULL
       ORDER BY 1;
      IF p_bit_no_set.COUNT = 0 THEN
        RETURN bit_map;
      END IF;

      FOR lvl IN 1 .. C_INDEX_DEPTH LOOP
        --setup bitmap array for all levels
        bit_map.extend;
        bit_map( lvl ) := bmap_node_list(0);
        IF lvl = 1 THEN
          --set bits on the lowest level
          FOR idx IN p_bit_no_set.FIRST .. p_bit_no_set.LAST LOOP
--            IF p_bit_no_set(idx) > C_MAX_BITS THEN
--              RAISE_APPLICATION_ERROR(-20000, 'Index size overflow');
--            END IF;
            bit_no :=      MOD( p_bit_no_set(idx) - 1, C_INDEX_LENGTH );
            bit_map_no := CEIL( p_bit_no_set(idx)    / C_INDEX_LENGTH );
            BEGIN
              bit_map(lvl)(bit_map_no) := bit_map(lvl)(bit_map_no) + POWER(2,bit_no);
            EXCEPTION
              WHEN E_SUBSCRIPT_BEYOND_COUNT THEN
                bit_map(lvl).EXTEND(bit_map_no-bit_map(lvl).LAST);
                bit_map(lvl)(bit_map_no) := POWER(2,bit_no);
            END;
          END LOOP;
        ELSE
          first_node := CEIL( bit_map(lvl-1).FIRST /31);
          last_node := CEIL( bit_map(lvl-1).LAST /31);
          FOR node IN first_node .. last_node LOOP
            IF bit_map(lvl-1)(node) IS NULL THEN
             -- node := bit_map(lvl-1).NEXT(node);
              CONTINUE;
            END IF;
            bit_no :=      MOD( node - 1, C_INDEX_LENGTH );
            bit_map_no := CEIL( node    / C_INDEX_LENGTH );
            IF NOT bit_map(lvl).exists(bit_map_no) THEN
              bit_map(lvl).EXTEND(bit_map_no-bit_map(lvl).LAST);
              bit_map(lvl)(bit_map_no) := POWER(2,bit_no);
            ELSE
              bit_map(lvl)(bit_map_no) := bitor( bit_map(lvl)(bit_map_no), POWER(2,bit_no) );
              bit_map(lvl)(bit_map_no) := bit_map(lvl)(bit_map_no) + POWER(2,bit_no) - BITAND( bit_map(lvl)(bit_map_no), POWER(2,bit_no) );
            END IF;
          END LOOP;
        END IF;
      END LOOP;
    END IF;
    RETURN bit_map;
  END bit_no_lst_to_bit_map;

  FUNCTION bit_no_lst_to_bit_map1(
    p_bit_no_lst INT_LIST
  ) RETURN BMAP_LEVEL_LIST IS
    p_bit_no_set INT_LIST := INT_LIST();
    bit_map BMAP_LEVEL_LIST := BMAP_LEVEL_LIST();

    bit_no        SIMPLE_INTEGER := 0;
    bit_map_no    SIMPLE_INTEGER := 0;
    max_bit_no    NUMBER;
--    node          NUMBER;
    first_node    NUMBER;
    last_node     NUMBER;
    E_SUBSCRIPT_BEYOND_COUNT EXCEPTION;
    PRAGMA EXCEPTION_INIT( E_SUBSCRIPT_BEYOND_COUNT, -6533 );
  BEGIN
    IF p_bit_no_lst IS NOT NULL AND CARDINALITY(p_bit_no_lst) != 0 THEN
      SELECT MAX(COLUMN_VALUE)
        INTO max_bit_no
        FROM TABLE(p_bit_no_lst);
      IF max_bit_no > C_MAX_BITS THEN
        RAISE_APPLICATION_ERROR(-20000, 'Index size overflow');
      END IF;
      --deduplicate, remove NULL and sort
      SELECT DISTINCT COLUMN_VALUE
        BULK COLLECT INTO p_bit_no_set
        FROM TABLE(p_bit_no_lst)
       WHERE COLUMN_VALUE IS NOT NULL
       ORDER BY 1 DESC;
      IF p_bit_no_set.COUNT = 0 THEN
        RETURN bit_map;
      END IF;

      FOR lvl IN 1 .. C_INDEX_DEPTH LOOP
        --setup bitmap array for all levels
        bit_map.extend;
        bit_map( lvl ) := bmap_node_list(0);
        IF lvl = 1 THEN
          --set bits on the lowes level
          FOR idx IN p_bit_no_set.FIRST .. p_bit_no_set.LAST LOOP
            bit_no :=      MOD( p_bit_no_set(idx) - 1, C_INDEX_LENGTH );
            bit_map_no := CEIL( p_bit_no_set(idx)    / C_INDEX_LENGTH );
            BEGIN
              bit_map(lvl)(bit_map_no) := bit_map(lvl)(bit_map_no) + POWER(2,bit_no);
            EXCEPTION
              WHEN E_SUBSCRIPT_BEYOND_COUNT THEN
                bit_map(lvl).EXTEND(bit_map_no-bit_map(lvl).LAST);
                bit_map(lvl)(bit_map_no) := POWER(2,bit_no);
            END;
          END LOOP;
        ELSE
          first_node := CEIL( bit_map(lvl-1).FIRST /31);
          last_node := CEIL( bit_map(lvl-1).LAST /31);
          FOR node IN first_node .. last_node LOOP
            IF bit_map(lvl-1)(node) IS NULL THEN
              CONTINUE;
            END IF;
            bit_no :=      MOD( node - 1, C_INDEX_LENGTH );
            bit_map_no := CEIL( node    / C_INDEX_LENGTH );
            IF NOT bit_map(lvl).exists(bit_map_no) THEN
              bit_map(lvl).EXTEND(bit_map_no-bit_map(lvl).LAST);
              bit_map(lvl)(bit_map_no) := POWER(2,bit_no);
            ELSE
              bit_map(lvl)(bit_map_no) := bit_map(lvl)(bit_map_no) + POWER(2,bit_no) - BITAND( bit_map(lvl)(bit_map_no), POWER(2,bit_no) );
            END IF;
          END LOOP;
        END IF;
      END LOOP;
    END IF;
    RETURN bit_map;
  END bit_no_lst_to_bit_map1;

  FUNCTION bitor(
    a SIMPLE_INTEGER ,
    b SIMPLE_INTEGER ) RETURN SIMPLE_INTEGER
  IS
  BEGIN
    RETURN a + b - BITAND( a, b );
  END bitor;

  FUNCTION saveBitmapLst (
    bmap_list BMAP_LEVEL_LIST
  ) RETURN INTEGER
  IS
    bitmap_key INTEGER;
  BEGIN
    IF bmap_list IS EMPTY or bmap_list IS NULL THEN
      bitmap_key := 0;
    ELSE
      INSERT INTO hierarchical_bitmap_table VALUES(hierarchical_bitmap_key.nextval, anydata.ConvertCollection(bmap_list))
      RETURNING bitmap_key INTO bitmap_key;
    END IF;

    RETURN bitmap_key;
  END saveBitmapLst;

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
END BMAP_UTIL;
/

ALTER PACKAGE BMAP_UTIL COMPILE DEBUG BODY;
/
