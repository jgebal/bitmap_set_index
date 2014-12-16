CREATE OR REPLACE PACKAGE BODY MAPPING_UTIL AS
  FUNCTION trimKeyList(
    pt_key_list MAPPING_KEY_LIST
  ) RETURN MAPPING_KEY_LIST
  IS
    trimmed_key_list MAPPING_KEY_LIST := pt_key_list;
  BEGIN
    FOR i IN trimmed_key_list.first..trimmed_key_list.last LOOP
      IF trimmed_key_list(i) IS NULL THEN
        trimmed_key_list.delete(i);
      END IF;
    END LOOP;

    RETURN trimmed_key_list;
  END trimKeyList;

  FUNCTION getNextBitNo
    RETURN INTEGER
  IS
    bitNo INTEGER;
  BEGIN
    SELECT COUNT(1) INTO bitNo FROM bitmap_mapping_table;
    RETURN bitNo + 1;
  END getNextBitNo;

  FUNCTION getBitNo (
    pt_key_list MAPPING_KEY_LIST
  ) RETURN INTEGER
  IS
    bitNo INTEGER;
    trimmedKeyList MAPPING_KEY_LIST;
    nextBitNo INTEGER;
  BEGIN
    IF pt_key_list IS NULL OR pt_key_list IS EMPTY THEN
      bitNo := NULL;
    ELSE
      trimmedKeyList := trimKeyList(pt_key_list);
      BEGIN
        SELECT bit_no INTO bitNo
          FROM bitmap_mapping_table
         WHERE mapping_node = trimmedKeyList;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        nextBitNo := getNextBitNo;
        INSERT INTO  bitmap_mapping_table VALUES (nextBitNo, trimmedKeyList)
        RETURNING bit_no INTO bitNo;
      END;
    END IF;

    RETURN bitNo;
  END getBitNo;
END MAPPING_UTIL;
/

