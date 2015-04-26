CREATE OR REPLACE PACKAGE bmap_maint AUTHID CURRENT_USER AS

  PROCEDURE create_index;

  PROCEDURE drop_index;

END bmap_maint;
/

SHOW ERRORS
/
