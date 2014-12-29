ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE BODY bmap_persist AS

  FUNCTION insertBitmapLst(
    pt_bitmap_list BMAP_LEVEL_LIST
  ) RETURN INTEGER
  IS
    bitmap_key INTEGER;
    BEGIN
      IF pt_bitmap_list IS EMPTY OR pt_bitmap_list IS NULL THEN
        bitmap_key := 0;
      ELSE
        INSERT INTO hierarchical_bitmap_table
        VALUES ( hierarchical_bitmap_key.nextval, anydata.ConvertCollection( pt_bitmap_list ) )
        RETURNING bitmap_key INTO bitmap_key;
      END IF;

      RETURN bitmap_key;
    END insertBitmapLst;

  FUNCTION getBitmapLst(
    pi_bitmap_key INTEGER
  ) RETURN BMAP_LEVEL_LIST
  IS
    bmap_lst     BMAP_LEVEL_LIST;
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

      RETURN bmap_lst;
    END getBitmapLst;

  FUNCTION updateBitmapLst(
    pi_bitmap_key  INTEGER,
    pt_bitmap_list BMAP_LEVEL_LIST
  ) RETURN INTEGER
  IS
    result INTEGER;
    BEGIN
      IF pt_bitmap_list IS NULL OR pt_bitmap_list IS EMPTY THEN
        result := -1;
      ELSE
        UPDATE hierarchical_bitmap_table
        SET bmap = anydata.convertcollection( pt_bitmap_list )
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
