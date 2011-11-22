

-- Find all blocked sessions and who is blocking them
select sid,blocking_session,username,sql_id,event,machine,osuser,program,last_call_et from v$session where blocking_session > 0;

select * from dba_blockers
select * from dba_waiters

-- Find what the blocking session is doing
select sid,blocking_session,username,sql_id,event,state,machine,osuser,program,last_call_et from v$session where sid=746 ;

-- Find the blocked objects
select owner,object_name,object_type from dba_objects where object_id in (select object_id from v$locked_object where session_id=271 and locked_mode =3);


-- Friendly query for who is blocking who
-- Mostly for versions before v$session had blocking_session column
select s1.inst_id,s2.inst_id,s1.username || '@' || s1.machine
 || ' ( SID=' || s1.sid || ' )  is blocking '
 || s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' AS blocking_status
  from gv$lock l1, gv$session s1, gv$lock l2, gv$session s2
  where s1.sid=l1.sid and s2.sid=l2.sid and s1.inst_id=l1.inst_id and s2.inst_id=l2.inst_id
  and l1.BLOCK=1 and l2.request > 0
  and l1.id1 = l2.id1
  and l2.id2 = l2.id2
order by s1.inst_id;


-- find blocking sessions that were blocking for more than 15 minutes + objects and sql
select s.SID,p.SPID,s.machine,s.username,CTIME/60 as minutes_locking, do.object_name as locked_object, q.sql_text
from v$lock l
join v$session s on l.sid=s.sid
join v$process p on p.addr = s.paddr
join v$locked_object lo on l.SID = lo.SESSION_ID
join dba_objects do on lo.OBJECT_ID = do.OBJECT_ID 
join v$sqlarea q on  s.sql_hash_value = q.hash_value and s.sql_address = q.address
where block=1 and ctime/60>15

-- Check who is blocking who in RAC
SELECT DECODE(request,0,'Holder: ','Waiter: ') || sid sess, id1, id2, lmode, request, type
FROM gv$lock
WHERE (id1, id2, type) IN (
  SELECT id1, id2, type FROM gv$lock WHERE request>0)
ORDER BY id1, request;

-- Check who is blocking who in RAC, including objects
SELECT DECODE(request,0,'Holder: ','Waiter: ') || gv$lock.sid sess, machine, do.object_name as locked_object,id1, id2, lmode, request, gv$lock.type
FROM gv$lock join gv$session on gv$lock.sid=gv$session.sid and gv$lock.inst_id=gv$session.inst_id
join gv$locked_object lo on gv$lock.SID = lo.SESSION_ID and gv$lock.inst_id=lo.inst_id
join dba_objects do on lo.OBJECT_ID = do.OBJECT_ID 
WHERE (id1, id2, gv$lock.type) IN (
  SELECT id1, id2, type FROM gv$lock WHERE request>0)
ORDER BY id1, request;




-- Who is blocking who, with some decoding
select	sn.USERNAME,
	m.SID,
	sn.SERIAL#,
	m.TYPE,
	decode(LMODE,
		0, 'None',
		1, 'Null',
		2, 'Row-S (SS)',
		3, 'Row-X (SX)',
		4, 'Share',
		5, 'S/Row-X (SSX)',
		6, 'Exclusive') lock_type,
	decode(REQUEST,
		0, 'None', 
		1, 'Null',
		2, 'Row-S (SS)',
		3, 'Row-X (SX)', 
		4, 'Share', 
		5, 'S/Row-X (SSX)',
		6, 'Exclusive') lock_requested,
	m.ID1,
	m.ID2,
	t.SQL_TEXT
from 	v$session sn, 
	v$lock m , 
	v$sqltext t
where 	t.ADDRESS = sn.SQL_ADDRESS 
and 	t.HASH_VALUE = sn.SQL_HASH_VALUE 
and 	((sn.SID = m.SID and m.REQUEST != 0) 
or 	(sn.SID = m.SID and m.REQUEST = 0 and LMODE != 4 and (ID1, ID2) in
        (select s.ID1, s.ID2 
         from 	v$lock S 
         where 	REQUEST != 0 
         and 	s.ID1 = m.ID1 
         and 	s.ID2 = m.ID2)))
order by sn.USERNAME, sn.SID, t.PIECE

-- Who is blocking who, with some decoding
select	OS_USER_NAME os_user,
	PROCESS os_pid,
	ORACLE_USERNAME oracle_user,
	l.SID oracle_id,
	decode(TYPE,
		'MR', 'Media Recovery',
		'RT', 'Redo Thread',
		'UN', 'User Name',
		'TX', 'Transaction',
		'TM', 'DML',
		'UL', 'PL/SQL User Lock',
		'DX', 'Distributed Xaction',
		'CF', 'Control File',
		'IS', 'Instance State',
		'FS', 'File Set',
		'IR', 'Instance Recovery',
		'ST', 'Disk Space Transaction',
		'TS', 'Temp Segment',
		'IV', 'Library Cache Invalidation',
		'LS', 'Log Start or Switch',
		'RW', 'Row Wait',
		'SQ', 'Sequence Number',
		'TE', 'Extend Table',
		'TT', 'Temp Table', type) lock_type,
	decode(LMODE,
		0, 'None',
		1, 'Null',
		2, 'Row-S (SS)',
		3, 'Row-X (SX)',
		4, 'Share',
		5, 'S/Row-X (SSX)',
		6, 'Exclusive', lmode) lock_held,
	decode(REQUEST,
		0, 'None',
		1, 'Null',
		2, 'Row-S (SS)',
		3, 'Row-X (SX)',
		4, 'Share',
		5, 'S/Row-X (SSX)',
		6, 'Exclusive', request) lock_requested,
	decode(BLOCK,
		0, 'Not Blocking',
		1, 'Blocking',
		2, 'Global', block) status,
	OWNER,
	OBJECT_NAME
from	v$locked_object lo,
	dba_objects do,
	v$lock l
where 	lo.OBJECT_ID = do.OBJECT_ID
AND     l.SID = lo.SESSION_ID
and block=1



