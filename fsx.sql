----------------------------------------------------------------------------------------
--
-- File name:   fsx.sql
--
-- Purpose:     Find SQL and report whether it was Offloaded and % of I/O saved.
--
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for two values.
--
--              sql_text: a piece of a SQL statement like %select col1, col2 from skew%
--
--              sql_id: the sql_id of the statement if you know it (leave blank to ignore)
--
-- Description:
--
--              This script can be used to locate statements in the shared pool and 
--              determine whether they have been executed via Smart Scans.
--
--              It is based on the observation that the IO_CELL_OFFLOAD_ELIGIBLE_BYTES
--              column in V$SQL is only greater than 0 when a statement is executed
--              using a Smart Scan. The IO_SAVED_% column attempts to show the ratio of
--              of data received from the storage cells to the actual amount of data
--              that would have had to be retrieved on non-Exadata storage. Note that 
--              as of 11.2.0.2, there are issues calculating this value with some queries.
--
--              Note that the AVG_ETIME will not be acurate for parallel queries. The 
--              ELAPSED_TIME column contains the sum of all parallel slaves. So the 
--              script divides the value by the number of PX slaves used which gives an 
--              approximation. 
--
--              Note also that if parallel slaves are spread across multiple nodes on
--              a RAC database the PX_SERVERS_EXECUTIONS column will not be set.
--
--              See kerryosborne.oracle-guy.com for additional information.
---------------------------------------------------------------------------------------
set pagesize 999
set lines 190
col sql_text format a70 trunc
col child format 99999
col execs format 9,999
col avg_etime format 99,999.99
col "IO_SAVED_%" format 999.99
col avg_px format 999
col offload for a7

select sql_id, child_number child, plan_hash_value plan_hash, executions execs, 
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions)/
decode(px_servers_executions,0,1,px_servers_executions/decode(nvl(executions,0),0,1,executions)) avg_etime, 
px_servers_executions/decode(nvl(executions,0),0,1,executions) avg_px,
decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'No','Yes') Offload,
decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,0,100*(IO_CELL_OFFLOAD_ELIGIBLE_BYTES-IO_INTERCONNECT_BYTES)
/decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,1,IO_CELL_OFFLOAD_ELIGIBLE_BYTES)) "IO_SAVED_%",
sql_text
from v$sql s
where upper(sql_text) like upper(nvl(q'[&sql_text]',sql_text))
and sql_text not like 'BEGIN :sql_text := %'
and sql_text not like '%IO_CELL_OFFLOAD_ELIGIBLE_BYTES%'
and sql_text not like '/* SQL Analyze(%'
and sql_id like nvl('&sql_id',sql_id)
order by 1, 2, 3
/
