-- undo generated in last day
SELECT TO_CHAR(BEGIN_TIME, 'MM/DD/YYYY HH24:MI:SS') BEGIN_TIME,
         TO_CHAR(END_TIME, 'MM/DD/YYYY HH24:MI:SS') END_TIME,
         UNDOTSN, UNDOBLKS, TXNCOUNT, MAXCONCURRENCY AS "MAXCON"
         FROM v$UNDOSTAT WHERE rownum <= 144;
         
    SELECT MAX(undoblks/((end_time-begin_time)*3600*24))
          "UNDO_BLOCK_PER_SEC"
      FROM v$undostat;

    SELECT TO_NUMBER(value) "DB_BLOCK_SIZE [KByte]"
     FROM v$parameter
    WHERE name = 'db_block_size';


         
-- Do I have enough space in my undo?    
SELECT CASE ROUND((TOTAL_USED_UNDO/UNDO_TBS_SIZE)*100) WHEN 0 THEN 1 ELSE ROUND((TOTAL_USED_UNDO/UNDO_TBS_SIZE)*100) END AS UNDO_USED_PERCENT, TOTAL_USED_UNDO, UNDO_TBS_SIZE  FROM (SELECT (SUM(BYTES)/1024/1024) AS UNDO_TBS_SIZE FROM DBA_DATA_FILES  WHERE TABLESPACE_NAME = (SELECT VALUE FROM V$PARAMETER WHERE NAME='undo_tablespace')) JOIN (SELECT (SUM(UNDOBLKS)*8)/1024 AS TOTAL_USED_UNDO FROM V$UNDOSTAT US WHERE US.BEGIN_TIME >= SYSDATE - (select case when to_number(value) < 3600 then to_number(value)/60/1440 else to_number(value)/3600/24 end  from v$parameter where name='undo_retention')) ON 1=1
         
  
-- who is eating undo?       
select * from v$transaction
select * from v$session where saddr='0000000198CA1C08'
select sid, sql_text
from v$session s, v$sql q
where sid in (1065)
and (
   q.sql_id = s.sql_id or
   q.sql_id = s.prev_sql_id);
   
   
--- retention on LOB:
select bitand(flags,32) from sys.lob$ where OBJ#= (select OBJECT_ID from dba_objects where
OWNER='RESPOND' and OBJECT_NAME='CONTENT')


select tablespace_name, extent_management,  segment_space_management
from dba_tablespaces
where tablespace_name in
  (select tablespace_name from dba_segments
   where owner='RESPOND' and segment_name='CONTENT');