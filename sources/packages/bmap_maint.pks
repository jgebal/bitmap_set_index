ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

ALTER SESSION SET PLSQL_CODE_TYPE = NATIVE;
/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
/

CREATE OR REPLACE PACKAGE bmap_maint AUTHID CURRENT_USER AS

  PROCEDURE create_index;

  PROCEDURE drop_index;

  PROCEDURE create_index_storage_table(
    p_table_name VARCHAR2
  );

END bmap_maint;
/

SHOW ERRORS
/
