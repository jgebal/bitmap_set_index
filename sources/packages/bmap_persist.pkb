ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE BODY bmap_persist AS

  FUNCTION convertForStorage(
    pt_bitmap_list BMAP_LEVEL_LIST
  ) RETURN STORAGE_BMAP_LEVEL_LIST IS
    node_list STORAGE_BMAP_NODE_LIST := STORAGE_BMAP_NODE_LIST();
    level_list STORAGE_BMAP_LEVEL_LIST := STORAGE_BMAP_LEVEL_LIST();
    j PLS_INTEGER;
    BEGIN
      IF NOT (pt_bitmap_list IS NULL OR pt_bitmap_list.COUNT = 0) THEN
        FOR i IN pt_bitmap_list.FIRST .. pt_bitmap_list.LAST LOOP
          level_list.EXTEND;
          j := pt_bitmap_list(i).FIRST;
          WHILE j IS NOT NULL LOOP
            node_list.EXTEND;
            node_list(node_list.LAST) := STORAGE_BMAP_NODE( j, pt_bitmap_list(i)(j) );
            j := pt_bitmap_list(i).NEXT( j );
          END LOOP;
          level_list(level_list.LAST) := node_list;
        END LOOP;
      END IF;
      RETURN level_list;
    END convertForStorage;

  FUNCTION convertForProcessing(
    pt_bitmap_list STORAGE_BMAP_LEVEL_LIST
  ) RETURN BMAP_LEVEL_LIST IS
    level_list BMAP_LEVEL_LIST;
    j PLS_INTEGER;
    BEGIN
      IF NOT (pt_bitmap_list IS NULL OR CARDINALITY(pt_bitmap_list) = 0) THEN
        FOR i IN pt_bitmap_list.FIRST .. pt_bitmap_list.LAST LOOP
          FOR j IN pt_bitmap_list(i).FIRST .. pt_bitmap_list(i).LAST LOOP
            level_list(i)(pt_bitmap_list(i)(j).node_index) := pt_bitmap_list(i)(j).node_value;
          END LOOP;
        END LOOP;
      END IF;
      RETURN level_list;
    END convertForProcessing;

  FUNCTION insertBitmapLst(
    pt_bitmap_list BMAP_LEVEL_LIST
  ) RETURN INTEGER
  IS
    bitmap_key INTEGER;
    bmap_anydata ANYDATA;
    BEGIN
      IF  pt_bitmap_list IS NULL OR pt_bitmap_list.COUNT = 0 THEN
        bitmap_key := 0;
      ELSE
        bmap_anydata := anydata.ConvertCollection( convertForStorage( pt_bitmap_list ) );
        INSERT INTO hierarchical_bitmap_table
        VALUES ( hierarchical_bitmap_key.nextval, bmap_anydata )
        RETURNING bitmap_key INTO bitmap_key;
      END IF;

      RETURN bitmap_key;
    END insertBitmapLst;

  FUNCTION getBitmapLst(
    pi_bitmap_key INTEGER
  ) RETURN BMAP_LEVEL_LIST
  IS
    bmap_lst     STORAGE_BMAP_LEVEL_LIST;
    bmap_anydata ANYDATA;
    is_ok        PLS_INTEGER;
    BEGIN
      IF pi_bitmap_key IS NOT NULL THEN
        BEGIN
          SELECT
            bmap
          INTO bmap_anydata
          FROM hierarchical_bitmap_table t
          WHERE t.bitmap_key = pi_bitmap_key;

          is_ok := anydata.getCollection( bmap_anydata, bmap_lst );
          EXCEPTION WHEN NO_DATA_FOUND
          THEN bmap_lst := NULL;
        END;
      ELSE
        bmap_lst := NULL;
      END IF;

      RETURN convertForProcessing(bmap_lst);
    END getBitmapLst;

  FUNCTION updateBitmapLst(
    pi_bitmap_key  INTEGER,
    pt_bitmap_list BMAP_LEVEL_LIST
  ) RETURN INTEGER
  IS
    bmap_anydata ANYDATA;
    result INTEGER;
    BEGIN
      IF pt_bitmap_list IS NULL OR pt_bitmap_list.COUNT = 0 THEN
        result := -1;
      ELSE
        bmap_anydata := anydata.ConvertCollection( convertForStorage( pt_bitmap_list ) );
        UPDATE hierarchical_bitmap_table
        SET bmap = bmap_anydata
        WHERE bitmap_key = pi_bitmap_key;
        result := SQL%ROWCOUNT;
      END IF;

      RETURN result;
    END updateBitmapLst;

  FUNCTION deleteBitmapLst(
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
        result := SQL%ROWCOUNT;
      END IF;

      RETURN result;
    END deleteBitmapLst;

  PROCEDURE setBitmapLst(
    pi_bitmap_key     IN OUT INTEGER,
    pt_bitmap_list           BMAP_LEVEL_LIST,
    pio_affected_rows OUT    INTEGER
  )
  IS
    BEGIN
      IF pi_bitmap_key IS NULL THEN
        pi_bitmap_key := insertBitmapLst( pt_bitmap_list );
      ELSE
        pio_affected_rows := updateBitmapLst( pi_bitmap_key, pt_bitmap_list );
        IF pio_affected_rows = -1 THEN
          pio_affected_rows := deleteBitmapLst( pi_bitmap_key );
        END IF;
      END IF;
    END setBitmapLst;

END bmap_persist;
/

SHOW ERRORS
/
