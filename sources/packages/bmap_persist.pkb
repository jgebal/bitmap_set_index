ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE BODY bmap_persist AS

  PROCEDURE insertBitmapSegment(
    pi_bitmap_key    INTEGER,
    pi_segment_V_pos INTEGER,
    pi_segment_H_pos INTEGER,
    pi_segment STOR_BMAP_SEGMENT
  ) IS
    bmap_anydata ANYDATA;
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    bmap_anydata := anydata.ConvertCollection(  pi_segment );
    INSERT
      INTO hierarchical_bitmap_table1
           ( bmap_key, bmap_h_pos, bmap_v_pos, bmap )
    VALUES ( pi_bitmap_key, pi_segment_H_pos, pi_segment_V_pos, bmap_anydata );
    COMMIT;
  END insertBitmapSegment;

  FUNCTION insertBitmapLst(
    pt_bitmap_list BMAP_SEGMENT
  ) RETURN INTEGER IS
    bitmap_key INTEGER;
    bmap_anydata ANYDATA;
    BEGIN
      IF  pt_bitmap_list IS NULL OR pt_bitmap_list.COUNT = 0 THEN
        bitmap_key := 0;
      ELSE
        bmap_anydata := anydata.ConvertCollection( bmap_builder.convert_for_storage( pt_bitmap_list ) );
        INSERT INTO hierarchical_bitmap_table
        VALUES ( hierarchical_bitmap_key.nextval, bmap_anydata )
        RETURNING bitmap_key INTO bitmap_key;
      END IF;

      RETURN bitmap_key;
    END insertBitmapLst;

  FUNCTION getBitmapLst(
    pi_bitmap_key INTEGER
  ) RETURN BMAP_SEGMENT IS
    bmap_lst     STOR_BMAP_SEGMENT;
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

      RETURN bmap_builder.convert_for_processing(bmap_lst);
    END getBitmapLst;

  FUNCTION updateBitmapLst(
    pi_bitmap_key  INTEGER,
    pt_bitmap_list BMAP_SEGMENT
  ) RETURN INTEGER IS
    bmap_anydata ANYDATA;
    result INTEGER;
    BEGIN
      IF pt_bitmap_list IS NULL OR pt_bitmap_list.COUNT = 0 THEN
        result := -1;
      ELSE
        bmap_anydata := anydata.ConvertCollection( bmap_builder.convert_for_storage( pt_bitmap_list ) );
        UPDATE hierarchical_bitmap_table
        SET bmap = bmap_anydata
        WHERE bitmap_key = pi_bitmap_key;
        result := SQL%ROWCOUNT;
      END IF;

      RETURN result;
    END updateBitmapLst;

  FUNCTION deleteBitmapLst(
    pi_bitmap_key INTEGER
  ) RETURN INTEGER IS
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

  FUNCTION setBitmapLst(
    pio_bitmap_key IN OUT INTEGER,
    pt_bitmap_list BMAP_SEGMENT
  ) RETURN INTEGER IS
    rows_affected INTEGER;
    BEGIN
      IF pio_bitmap_key IS NULL THEN
        pio_bitmap_key := insertBitmapLst( pt_bitmap_list );
      ELSE
        rows_affected := updateBitmapLst( pio_bitmap_key, pt_bitmap_list );
        IF rows_affected = -1 THEN
          rows_affected := deleteBitmapLst( pio_bitmap_key );
        END IF;
      END IF;
      RETURN rows_affected;
    END setBitmapLst;

END bmap_persist;
/

SHOW ERRORS
/
