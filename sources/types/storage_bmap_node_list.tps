BEGIN EXECUTE IMMEDIATE 'DROP TYPE STORAGE_BMAP_NODE_LIST FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

CREATE OR REPLACE TYPE STORAGE_BMAP_NODE_LIST AS TABLE OF STORAGE_BMAP_NODE;
/