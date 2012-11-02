set long 100000000
set pages 400 lines 400
col report format a400

 select DBMS_SQLTUNE.REPORT_SQL_MONITOR(SQL_ID=>'&1') as report from dual;