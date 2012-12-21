-- by Jeremy Schneider, Pythian
clear breaks
col sql_text format a40
col wait_class format a20
col event format a40
col top_obj_pct format a11
col top_object format a30
break on sql_id on sql_text skip 1

with master as (
select /*+ materialize */ hhh.sql_id,
       trunc(100*count(*)/hhh.total_sess) percentage,
       hhh.wait_class, 
       hhh.event,
       hhh.top_obj,
       decode(hhh.top_obj,0,null,-1,null,trunc(100*hhh.total_top_obj/hhh.total_sess)) top_obj_pct,
       count(*) total_samples,
       hhh.topn
from (
  select hh.*,
         first_value(hh.current_obj#) over (partition by hh.sql_id, hh.event order by hh.total_obj desc nulls last) top_obj,
         first_value(hh.total_obj) over (partition by hh.sql_id, hh.event order by hh.total_obj desc nulls last) total_top_obj,
         dense_rank() over (partition by hh.sql_id order by hh.total_ev desc) topn_ev,
         dense_rank() over (order by total_sess desc) topn
  from (
    select h.sql_id, case when h.session_state='WAITING' then h.wait_class else 'CPU' end wait_class, 
           case when h.session_state='WAITING' then h.event else 'CPU' end event, h.current_obj#, 
           count(*) over (partition by h.sql_id) total_sess, 
           count(*) over (partition by h.sql_id, case when h.session_state='WAITING' then h.event else 'CPU' end) total_ev, 
           case when h.current_obj#>1 then count(*) over (partition by h.sql_id, h.current_obj#) else -1 end total_obj
    from dba_hist_active_sess_history h
    where h.instance_number=1
      --and h.session_state='WAITING'
      and h.sql_id is not null
      and h.sample_time between '&1' and '&2'
  ) hh
) hhh 
where 1=1
  and topn<=14
--  and topn_ev<=5
having 100*count(*)/hhh.total_sess>10  -- this wait event accounts for more than 10% of this SQL statement
group by hhh.sql_id, hhh.wait_class, hhh.event, hhh.total_sess, hhh.top_obj, hhh.total_top_obj, hhh.topn_ev, hhh.topn
)
select m.sql_id,
       dbms_lob.substr(t.sql_text,40,1) sql_text,
       m.percentage,
       m.wait_class,
       m.event,
--       m.top_obj,
       m.top_obj_pct,
       o.object_name top_object,
       o.object_type top_obj_type,
       m.total_samples
from master m, dba_hist_sqltext t, dba_objects o
where m.top_obj=o.object_id(+) and m.sql_id=t.sql_id
order by m.topn, m.percentage desc
/

