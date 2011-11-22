-- Find segments with most read operations, and hopefully relatively few writes
-- These are good candidates for placing on SSD storage
WITH segment_stats
          AS (SELECT ss.owner || '.' || ss.object_name
                    || DECODE (ss.subobject_name,NULL, '',
                    '(' || ss.subobject_name || ')')  segment_name,
                    ss.object_type,
                    SUM ( CASE WHEN statistic_name LIKE 'physical reads%'
                            THEN VALUE ELSE 0  END) reads,
                    SUM ( CASE WHEN statistic_name LIKE 'physical writes%'
                            THEN VALUE  ELSE 0 END) writes,
                    ROUND (SUM (bytes) / 1048576) mb
              FROM   v$segment_statistics ss
              JOIN   dba_segments s
               ON (s.owner = ss.owner AND s.segment_name = ss.object_name
                   AND NVL (ss.subobject_name, 'x') =NVL (s.partition_name, 'x'))
             WHERE statistic_name LIKE 'physical reads%'
                OR statistic_name LIKE 'physical writes%'
             GROUP BY ss.owner,ss.object_name,ss.subobject_name,ss.object_type) 
 SELECT segment_name, object_type, reads,writes,
       ROUND (reads * 100 / SUM (reads) OVER (), 2) pct_reads,
       ROUND (writes * 100 / SUM (writes) OVER (), 2) pct_writes,
       mb FROM segment_stats
 ORDER BY reads DESC

 -- find segments with full scans
 -- These are not ideal for placing on SSD storage
col segment_name format a60
select
        owner || '.' || object_name || DECODE (subobject_name,NULL, '','(' || subobject_name || ')') segment_name,object_type, 
        value scans
from
        V$segment_statistics
where
        statistic_name = 'segment scans'
and     value != 0
order by
	value desc 
;
