--preview the perf of PLSQL code
SELECT a.runid, a.run_owner, a.run_comment,
       a.run_total_time / 1000000000 run_secs,
       c.total_occur,
       c.total_time / 1000000000 line_total_secs,
       b.unit_type, b.unit_owner, b.unit_name, c.line#, u.text
  FROM plsql_profiler_runs a
  JOIN plsql_profiler_units b ON ( a.runid = b.runid )
  JOIN plsql_profiler_data c ON ( a.runid = c.runid AND b.unit_number = c.unit_number)
  LEFT JOIN dba_source u ON (b.unit_name = u.NAME AND b.unit_owner = u.owner AND c.line# = u.line AND b.unit_type = u.TYPE )
 WHERE 1=1
 --AND b.unit_owner <> 'EMACH'
--   AND b.unit_owner in ('MD','LOG4PLSQL')
   --AND  b.unit_owner = 'MACHXJGE'
   --AND unit_name = 'BITNADSPEEDTEST'
   AND total_occur > 0
--   AND RUN_COMMENT LIKE '%NEW%'
   AND C.total_time > 10000000
 ORDER BY a.runid DESC, line_total_secs DESC,
    unit_name, line
;
