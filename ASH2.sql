-- how much history do we have:
select min(sample_time) from V$ACTIVE_SESSION_HISTORY

-- top events
select event,count(*) from DBA_HIST_ACTIVE_SESS_HISTORY where sample_time> sysdate-1/24 
and user_id>0
group by event
order by count(*) desc;


-- top sql
select sql_id,count(*) from DBA_HIST_ACTIVE_SESS_HISTORY where sample_time> sysdate-1/24 
and user_id>0
group by sql_id
order by count(*) desc;


-- see specific samples
select sample_time,user_id,sql_id,event from DBA_HIST_ACTIVE_SESS_HISTORY
where 1=1
--and sample_time> to_date('03-MAR-11 15:30','dd-mon-yy hh24:mi')
and sample_time> sysdate-1/24
--and user_id>0
--and session_id=371
order by sample_time;

-- look for hot buffers
select p1,p2,p3,count(*) from DBA_HIST_ACTIVE_SESS_HISTORY
where sample_time> to_date('03-MAR-11 15:30','dd-mon-yy hh24:mi')
and  sample_time< to_date('03-MAR-11 16:30','dd-mon-yy hh24:mi')
and user_id>0
and event='buffer busy waits'
group by p1,p2,p3 
order by count(*)



           SELECT SEGMENT_NAME, SEGMENT_TYPE FROM DBA_EXTENTS            
                WHERE FILE_ID = 1  AND 231928 BETWEEN BLOCK_ID AND                  
                      BLOCK_ID + BLOCKS - 1;  
					  
					  
					  

-- top SQL waiting for a specific events
select sql_id,count(*) from DBA_HIST_ACTIVE_SESS_HISTORY
where sample_time> sysdate-1/24
and user_id>0
and event  is null
group by sql_id 
order by count(*)

-- top programs waiting for a specific events
select program,count(*) from DBA_HIST_ACTIVE_SESS_HISTORY
where sample_time> to_date('03-MAR-11 15:30','dd-mon-yy hh24:mi')
and  sample_time< to_date('03-MAR-11 16:30','dd-mon-yy hh24:mi')
and user_id>0
and event='buffer busy waits'
group by program
order by count(*)

-- top users waiting for a specific events
select user_id,count(*) from DBA_HIST_ACTIVE_SESS_HISTORY
where sample_time> to_date('03-MAR-11 15:30','dd-mon-yy hh24:mi')
and  sample_time< to_date('03-MAR-11 16:30','dd-mon-yy hh24:mi')
and user_id>0
and event='buffer busy waits'
group by user_id
order by count(*)  2    3    4    5    6    7  ;

-- Everyone waiting for specific event
select sample_time,user_id,sql_id,event,p1,blocking_session from V$ACTIVE_SESSION_HISTORY
where event like 'library%'

-- Who is waiting for specific event the most:
select SESSION_ID,user_id,sql_id,round(sample_time,'hh'),count(*) from V$ACTIVE_SESSION_HISTORY
where event like 'log file sync'
group by  SESSION_ID,user_id,sql_id,round(sample_time,'hh')
order by count(*) desc





select event,count(*) from DBA_HIST_ACTIVE_SESS_HISTORY
where sample_time> to_date('03-MAR-11 15:30','dd-mon-yy hh24:mi')
and  sample_time< to_date('03-MAR-11 16:00','dd-mon-yy hh24:mi')
and user_id>0
group by event
order by count(*) desc


select to_char(trunc(sample_time, 'hh24') + round((cast(sample_time as date)- trunc(cast(sample_time as date), 'hh24'))*60*24/5)*5/60/24, 'dd/mm/yyyy hh24:mi'),count(*) from DBA_HIST_ACTIVE_SESS_HISTORY
where sample_time> to_date('03-MAR-11 15:30','dd-mon-yy hh24:mi')
and  sample_time< to_date('03-MAR-11 16:30','dd-mon-yy hh24:mi')
and user_id=209
and event='buffer busy waits'
group by to_char(trunc(sample_time, 'hh24') + round((cast(sample_time as date)- trunc(cast(sample_time as date), 'hh24'))*60*24/5)*5/60/24, 'dd/mm/yyyy hh24:mi')
order by count(*)


select sql_id,count(*) from V$ACTIVE_SESSION_HISTORY
where sample_time> to_date('08-FEB-10 13:00','dd-mon-yy hh24:mi')
and  sample_time< to_date('08-FEB-10 16:00','dd-mon-yy hh24:mi')
and user_id>0
group by sql_id
order by count(*) desc

select * from dba_views where view_name like 'DBA_HIST%'

select sh.sample_time,sh.SESSION_ID,user_id,sh.sql_id,event,p1,blocking_session,PROGRAM,sql_text
from DBA_HIST_ACTIVE_SESS_HISTORY sh
left outer join  DBA_HIST_SQLTEXT  sq on sq.sql_id=sh.sql_id 
where 1=1 
and sample_time> to_date('08-FEB-10 00:00','dd-mon-yy hh24:mi')
and  sample_time< to_date('08-FEB-10 23:00','dd-mon-yy hh24:mi')
and user_id=61
--and sql_id='809u1jtt54kfy'
order by sample_time


select trunc(sample_time),
sum(case when INSTANCE_NUMBER=1 then 1 else 0 end) inst1,
sum(case when INSTANCE_NUMBER=2 then 1 else 0 end) inst2
from DBA_HIST_ACTIVE_SESS_HISTORY sh
where 1=1 
and user_id=61
group by trunc(sample_time)
order by trunc(sample_time)



select * from DBA_HIST_SQLTEXT where sql_id='d15cdr0zt3vtp';
where dbms_lob.instr(sql_text, 'GLOBAL',1,1) > 0

desc DBA_HIST_ACTIVE_SESS_HISTORY 

EXEC DBMS_MONITOR.session_trace_enable(session_id =>1234, serial_num=>1234, waits=>TRUE, binds=>FALSE);

select sample_time,user_id,sql_id,event,p1,blocking_session from V$ACTIVE_SESSION_HISTORY
where event like 'library%'

select * from v$active_session_history where session_id=306
6969666696
select SESSION_ID,user_id,sql_id,round(sample_time,'hh'),count(*) from V$ACTIVE_SESSION_HISTORY
where event like 'log file sync'
group by  SESSION_ID,user_id,sql_id,round(sample_time,'hh')
order by count(*) desc


select * from dba_users; 61
