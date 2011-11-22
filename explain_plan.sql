-- dbms_xplan works in 9i and up
-- display_cursor is 10g and up
-- first parameter is sql_id and second is child cursor
-- Default is the last query run in current session
-- 'ALLSTATS LAST' adds the actual execution stats alongside the predicted row counts.
select * from table(dbms_xplan.display_cursor('64t6vkhwv9ybw',null,'ALLSTATS LAST'));       

select * from table(dbms_xplan.display_cursor('2hbdag3dfzj9u'));

-- For more details and generally excellent report (11g only)
set pagesize 0 echo off timing off linesize 1000 trimspool on trim on long 2000000 longchunksize 2000000
select DBMS_SQLTUNE.REPORT_SQL_MONITOR('9vjmu2jrwj512') from dual;

-- older way to see plans
EXPLAIN PLAN
    SET STATEMENT_ID = 'bad' FOR
<...sql..>

SELECT cardinality "Rows",
       lpad(' ',level-1)||operation||' '||
       options||' '||object_name "Plan"
  FROM PLAN_TABLE
CONNECT BY prior id = parent_id
        AND prior statement_id = statement_id
  START WITH id = 0
        AND statement_id = 'bad2'
  ORDER BY id;





-- privileges needed
--If you want to call this function, you need access to several of the dynamic performance views -v$session, v$sql, v$sql_plan and v$sql_plan_statistics_all seem to cover all the options between them; and v$sql_plan_statistics_all is the most useful one.


