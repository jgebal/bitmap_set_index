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
