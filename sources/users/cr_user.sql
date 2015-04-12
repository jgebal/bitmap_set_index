create user usr identified by usr DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp;
grant connect, resource, dba to usr;
