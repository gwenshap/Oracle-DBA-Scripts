set serveroutput on
declare
clobsqltext CLOB;
v_start_snap_id number := 110;
v_end_snap_id number := 131;
begin
for v_sql_id in (select sql_id,count(*) cnt from (
select snap_id, sql_id,
buffer_gets_delta,
dense_rank() over (partition by snap_id order by buffer_gets_delta desc) gets_rank,
cpu_time_delta,
dense_rank() over (partition by snap_id order by cpu_time_delta desc) cpu_rank,
elapsed_time_delta,
dense_rank() over (partition by snap_id order by elapsed_time_delta desc) elapsed_rank
--,executions_delta
--,dense_rank() over (partition by snap_id order by executions_delta desc) executions_rank
from sys.wrh$_sqlstat
where snap_id>=v_start_snap_id and snap_id<=v_end_snap_id)
where gets_rank<=5 or cpu_rank<=5 or elapsed_rank<=5 
--or executions_rank<=5
group by sql_id
order by cnt desc)
loop
dbms_output.put_line('SQL='||v_sql_id.sql_id || ' was top SQL ' || v_sql_id.cnt || ' times');

for line in (select plan_table_output from table(DBMS_XPLAN.DISPLAY_AWR(v_sql_id.sql_id)))
loop
dbms_output.put_line(line.plan_table_output);
END LOOP;

for line in (select snap_id,executions_delta execs,
round(buffer_gets_delta/executions_delta,2) gets_per_exec,
round(rows_processed_delta/executions_delta,2) rows_per_exec,
round((elapsed_time_delta/1000000)/executions_delta,2) ela_per_exec
from sys.wrh$_sqlstat
where sql_id=v_sql_id.sql_id
and executions_delta > 0)
loop
dbms_output.put_line('snapshot = ' || line.snap_id || ' ** execs = ' || line.execs
|| ' ** gets_per_exec = ' || line.gets_per_exec || ' ** rows_per_exec ' || line.rows_per_exec || ' ** ela_per_exec '|| line.ela_per_exec);
end loop;

for line in ( select snap_id,name, position, datatype_string, value_string from dba_hist_sqlbind where sql_id=v_sql_id.sql_id)
loop
if line.value_string is not null then
dbms_output.put_line('**** bind variables for snapshot = ' || line.snap_id || ' name=' || line.name
|| ' position=' || line.position || ' datatype=' || line.datatype_string || ' value=' || line.value_string);
end if;
end loop;
end loop;
END;
/