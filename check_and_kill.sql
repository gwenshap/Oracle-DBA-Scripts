-- Check what the sessions in our instance are waiting for
select event,count(*) from v$session group by event order by count(*);

-- Flexible query to check what's currently running in the system
-- Where statement and column lists can be modified by the case
-- Written for RAC DBs
select 
s.inst_id,
--      'alter system kill session '''|| s.SID||',' || s.serial# ||'''' ,
--'!kill -9 ' || p.spid, 
      p.SPID UnixProcess ,s.SID,s.serial#,s.USERNAME,s.COMMAND,s.MACHINE,s.blocking_session
      ,s.program, status,state,event,s.sql_id,sql_text,COMMAND_TYPE
--    ,sbc.name,to_char(sbc.last_captured,'yyyy-mm-dd hh24:mi:ss'),sbc.value_string
    from gv$session s
left outer join gv$process p on p.ADDR = s.PADDR and s.inst_id=p.inst_id 
left outer join gv$sqlarea sa on sa.ADDRESS = s.SQL_ADDRESS and s.inst_id=sa.inst_id
--left outer join gV$SQL_BIND_CAPTURE sbc on sbc.ADDRESS = s.SQL_ADDRESS and s.inst_id=p.inst_id
where 1=1 and sql_text like '...'

-- Check what a specific session is doing:
select 
      p.SPID UnixProcess ,s.SID,s.serial#,s.USERNAME,s.COMMAND,s.MACHINE,s.SQL_ADDRESS,s.SQL_HASH_VALUE
      ,s.program, status,sql_text,COMMAND_TYPE
    from gv$session s,gv$process p, gv$sqlarea sa
	where p.ADDR = s.PADDR and s.inst_id=p.inst_id 
	and sa.ADDRESS = s.SQL_ADDRESS and s.inst_id=sa.inst_id
	and s.sid=1722;

-- Find all sessions that are blocked and which session is blocking them
-- Then find what the blocking session is doing
select sid,blocking_session,username,sql_id,event,machine,osuser,program from v$session where blocking_session > 0;
select sid,blocking_session,username,sql_id,event,machine,osuser,program from v$session where sid=491;


-- generate commands to kill all sessions from a specific user on specific instance
select 'alter system kill session '''|| SID||',' || serial# ||''' immediate;' from gv$session where username='BAD_USER' and inst_id=1;


-- Kill all sessions waiting for specific events by a specific user
select       'alter system kill session '''|| s.SID||',' || s.serial# ||''';' 
from gv$session s
where 1=1 
and (event='latch: shared pool' or event='library cache lock') and s.USERNAME='DBSNMP';

-- kill all sessions executing a bad SQL
select 
     'alter system kill session '''|| s.SID||',' || s.serial# ||''';' 
    from v$session s
where s.sql_id='0vj44a7drw1rj';


-- Sessions taking most PGA memory
-- Can be used to find leaks
select addr,SPID,username,program,pga_alloc_mem/1024 mem_alloc_Kb from v$process order by pga_alloc_mem;

-- Check what is the top SQL executed by parallel slaves
select sql_id,count(*) from v$session where program like '%P0%' group by sql_id;



-- Find inactive sessions
-- This can be used to decide which sessions to kill if the DB is running out of processes
select sid, blocking_session,username,program,machine,osuser,  sql_id, prev_sql_id, event,LAST_CALL_ET from v$session where status != 'ACTIVE' and last_call_et>3600;


-- How many sessions openned by each app server
select machine,count(*) from gv$session s group by machine;

-- Find sql_id for a specific sql snippet
select sql_id,sql_text from v$sql where dbms_lob.instr(sql_text, 'create INDEX',1,1) > 0

-- Find SQL with too many child cursors:
select version_count,sql_text from v$sqlarea order by version_count desc



-- Get the longops status for a specific session
	select sid
	,      message, start_time,time_remaining 
	from   v$session_longops
	where  sid = 28
	order by start_time;

-- Check status for long ops executing right now
  select s.sid,s.serial#,opname, target, program,sofar, totalwork,units, elapsed_seconds, message,start_time,time_remaining   
from v$session_longops l
join v$session s on l.sid=s.sid and s.serial#=l.serial#
where time_remaining>0
order by start_time desc




-- Find out how much memory each session is using
COLUMN sid                     FORMAT 999            HEADING 'SID'
COLUMN oracle_username         FORMAT a12            HEADING 'Oracle User'     JUSTIFY right
COLUMN os_username             FORMAT a9             HEADING 'O/S User'        JUSTIFY right
COLUMN session_program         FORMAT a18            HEADING 'Session Program' TRUNC
COLUMN session_module         FORMAT a18            HEADING 'Session module' TRUNC
COLUMN session_action         FORMAT a18            HEADING 'Session action' TRUNC
COLUMN session_machine         FORMAT a8             HEADING 'Machine'   JUSTIFY right TRUNC
COLUMN session_pga_memory      FORMAT 9,999,999,999  HEADING 'PGA Memory'
COLUMN session_pga_memory_max  FORMAT 9,999,999,999  HEADING 'PGA Memory Max'
COLUMN session_uga_memory      FORMAT 9,999,999,999  HEADING 'UGA Memory'
COLUMN session_uga_memory_max  FORMAT 9,999,999,999  HEADING 'UGA Memory MAX'
COLUMN session_total_memory  FORMAT 9,999,999,999  HEADING 'Total Memory'

select sid,oracle_username,os_username,session_program,session_module,session_action, 
session_pga_memory,session_pga_memory_max,session_uga_memory,session_uga_memory_max,session_pga_memory+session_uga_memory session_total_memory from (
SELECT
    s.sid                sid
  , lpad(s.username,12)  oracle_username
  , lpad(s.osuser,9)     os_username
  , s.program            session_program
  , s.module            session_module
  , s.action            session_action
  , lpad(s.machine,8)    session_machine
  , (select ss.value from v$sesstat ss, v$statname sn
     where ss.sid = s.sid and 
           sn.statistic# = ss.statistic# and
           sn.name = 'session pga memory')        session_pga_memory
  , (select ss.value from v$sesstat ss, v$statname sn
     where ss.sid = s.sid and 
           sn.statistic# = ss.statistic# and
           sn.name = 'session pga memory max')    session_pga_memory_max
  , (select ss.value  from v$sesstat ss, v$statname sn
     where ss.sid = s.sid and 
           sn.statistic# = ss.statistic# and
           sn.name = 'session uga memory')        session_uga_memory
  , (select ss.value from v$sesstat ss, v$statname sn
     where ss.sid = s.sid and 
           sn.statistic# = ss.statistic# and
           sn.name = 'session uga memory max')   as session_uga_memory_max
FROM 
    v$session  s )
ORDER BY session_total_memory DESC;







