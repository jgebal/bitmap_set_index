BEGIN EXECUTE IMMEDIATE 'DROP TYPE INT_LIST FORCE' EXCEPTION WHEN OTHERS THEN NULL; END;
/

CREATE OR REPLACE TYPE INT_LIST AS TABLE OF INTEGER;
/
