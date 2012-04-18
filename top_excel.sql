select * from dba_hist_snapshot order by snap_id
108 132

with awr_ranks as
(
select snap_id, sql_id,
                           buffer_gets_delta,
                           dense_rank() over (partition by snap_id order by buffer_gets_delta desc) gets_rank,
                           cpu_time_delta,
                           dense_rank() over (partition by snap_id order by cpu_time_delta desc) cpu_rank,
                           elapsed_time_delta,
                           dense_rank() over (partition by snap_id order by elapsed_time_delta desc) elapsed_rank,
                           executions_delta,
                           dense_rank() over (partition by snap_id order by executions_delta desc) executions_rank
                     from sys.wrh$_sqlstat
), rank as
(
       select level rank from dual connect by level <= 5
)
select snap_id,
                           rank,
                           max(case gets_rank when rank then to_char(buffer_gets_delta)||': '||sql_id end) gets_sql,
                           max(case cpu_rank when rank then to_char(round(cpu_time_delta/1000000,2))||': '||sql_id end) cpu_sql,
                           max(case elapsed_rank when rank then to_char(round(elapsed_time_delta/1000000,2))||': '||sql_id end) elapsed_sql,
                           max(case executions_rank when rank then  to_char(executions_delta)||': '||sql_id end) executions_sql
              from awr_ranks, rank
              where snap_id between 110 and 131
              group by snap_id, rank
              order by snap_id, rank;