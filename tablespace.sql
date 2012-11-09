-- Tablespaces, ordered by percentage of space used

col bytes_used format 99999999999999 
SELECT a.TABLESPACE_NAME, a.BYTES/1024/1024 Mbytes_used,b.BYTES/1024/1024 Mbytes_free, round(((a.BYTES-b.BYTES)/a.BYTES)*100,2) percent_used from ( select TABLESPACE_NAME, sum(BYTES) BYTES from dba_data_files group by  TABLESPACE_NAME ) a left outer join  ( select TABLESPACE_NAME,sum(BYTES) BYTES ,max(BYTES) largest from dba_free_space group by TABLESPACE_NAME ) b on a.TABLESPACE_NAME=b.TABLESPACE_NAME where 1=1 and a.tablespace_name like '%' order by ((a.BYTES-b.BYTES)/a.BYTES) desc

-- List files in a tablespace with current size and max size
select file_name,bytes/1024/1024 Mbytes,autoextensible,maxbytes/1024/1024 M_maxbytes from dba_data_files where tablespace_name= 'MASTER_TBS';


-- List files in a volume with current size and max size
select file_name,bytes/1024/1024 Mbytes,autoextensible,maxbytes/1024/1024 M_maxbytes from dba_data_files where file_name like '/u04/oradata7/%' order by file_name;

-- Grow a datafile
ALTER DATABASE DATAFILE '/u05/oradata/COGPREPO/perfstat_01.dbf' resize 2048M;

-- add datafile
alter tablespace ALLHOTDB_DATA01 add datafile '/ihotelt3/oradata/ihotelt3/allhotdb_data01_07.dbf' size 10240M autoextend off;

-- Free temp space
SELECT tablespace_name,
       total_blocks,
       used_blocks,
       free_blocks,
    total_blocks*16/1024 as total_MB,
    used_blocks*16/1024 as used_MB,
    free_blocks*16/1024 as free_MB
FROM   v$sort_segment;
 
-- 
-- So what's using the segments:
-- 
SELECT   b.TABLESPACE,
         b.segfile#,
         b.segblk#,
         b.blocks,
   b.blocks*16/1024 as MB,
         a.SID,
         a.serial#,
         a.status
FROM     v$session a,
         v$sort_usage b
WHERE    a.saddr = b.session_addr
ORDER BY b.TABLESPACE,
         b.segfile#,
         b.segblk#,
         b.blocks;


