ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE BODY bmap_persist AS

  PROCEDURE insertBitmapSegment(
    p_bitmap_key    INTEGER,
    p_segment_V_pos INTEGER,
    p_segment_H_pos INTEGER,
    p_segment STOR_BMAP_SEGMENT
  ) IS
    v_bmap_anydata ANYDATA;
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    v_bmap_anydata := anydata.ConvertCollection(  p_segment );
    INSERT
      INTO hierarchical_bitmap_table1
           ( bmap_key, bmap_h_pos, bmap_v_pos, bmap )
    VALUES ( p_bitmap_key, p_segment_H_pos, p_segment_V_pos, v_bmap_anydata );
    COMMIT;
  END insertBitmapSegment;

  FUNCTION insertBitmapLst(
    p_bitmap_list BMAP_SEGMENT
  ) RETURN INTEGER IS
    v_bitmap_key INTEGER;
    v_bmap_anydata ANYDATA;
    BEGIN
      IF p_bitmap_list IS NULL OR p_bitmap_list.COUNT = 0 THEN
        v_bitmap_key := 0;
      ELSE
        v_bmap_anydata := anydata.ConvertCollection( bmap_builder.convert_for_storage( p_bitmap_list ) );
        INSERT INTO hierarchical_bitmap_table
        VALUES ( hierarchical_bitmap_key.nextval, v_bmap_anydata )
        RETURNING bitmap_key INTO v_bitmap_key;
      END IF;

      RETURN v_bitmap_key;
    END insertBitmapLst;

  FUNCTION getBitmapLst(
    p_bitmap_key INTEGER
  ) RETURN BMAP_SEGMENT IS
    v_bmap_lst     STOR_BMAP_SEGMENT;
    v_bmap_anydata ANYDATA;
    v_ok           PLS_INTEGER;
    BEGIN
      IF p_bitmap_key IS NOT NULL THEN
        BEGIN
          SELECT
            bmap
          INTO v_bmap_anydata
          FROM hierarchical_bitmap_table t
          WHERE t.bitmap_key = p_bitmap_key;

          v_ok := anydata.getCollection( v_bmap_anydata, v_bmap_lst );
          EXCEPTION WHEN NO_DATA_FOUND
          THEN v_bmap_lst := NULL;
        END;
      ELSE
        v_bmap_lst := NULL;
      END IF;

      RETURN bmap_builder.convert_for_processing(v_bmap_lst);
    END getBitmapLst;

  FUNCTION updateBitmapLst(
    p_bitmap_key  INTEGER,
    p_bitmap_list BMAP_SEGMENT
  ) RETURN INTEGER IS
    v_bmap_anydata ANYDATA;
    result INTEGER;
    BEGIN
      IF p_bitmap_list IS NULL OR p_bitmap_list.COUNT = 0 THEN
        result := -1;
      ELSE
        v_bmap_anydata := anydata.ConvertCollection( bmap_builder.convert_for_storage( p_bitmap_list ) );
        UPDATE hierarchical_bitmap_table
        SET bmap = v_bmap_anydata
        WHERE bitmap_key = p_bitmap_key;
        result := SQL%ROWCOUNT;
      END IF;

      RETURN result;
    END updateBitmapLst;

  FUNCTION deleteBitmapLst(
    p_bitmap_key INTEGER
  ) RETURN INTEGER IS
    v_result INTEGER;
    BEGIN
      IF p_bitmap_key IS NULL THEN
        v_result := 0;
      ELSE
        DELETE
        FROM hierarchical_bitmap_table
        WHERE bitmap_key = p_bitmap_key;
        v_result := SQL%ROWCOUNT;
      END IF;

      RETURN v_result;
    END deleteBitmapLst;

  FUNCTION setBitmapLst(
    p_bitmap_key IN OUT INTEGER,
    p_bitmap_list BMAP_SEGMENT
  ) RETURN INTEGER IS
    v_rows_affected INTEGER;
    BEGIN
      IF p_bitmap_key IS NULL THEN
        p_bitmap_key := insertBitmapLst( p_bitmap_list );
      ELSE
        v_rows_affected := updateBitmapLst( p_bitmap_key, p_bitmap_list );
        IF v_rows_affected = -1 THEN
          v_rows_affected := deleteBitmapLst( p_bitmap_key );
        END IF;
      END IF;
      RETURN v_rows_affected;
    END setBitmapLst;

END bmap_persist;
/

SHOW ERRORS
/
