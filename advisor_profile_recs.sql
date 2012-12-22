
-- Retrieve SQL tuning advisor findings. You can only run the most recent run if you like, but it will only contain new recommendations. This syntax will retrieve all recommendations, including those that have since been modified
-- Warning: it generates quite a bit of output, as it has every tuning recommendation.

select dbms_sqltune.report_auto_tuning_task((select min(execution_name) from dba_advisor_findings where task_name like 'SYS_AUTO_SQL%'),
(select max(execution_name) from dba_advisor_findings where task_name like 'SYS_AUTO_SQL%')) from dual;


--  Note the execution name and object ID for the recommendation
-- Use this information to query out the hints from dba_advisor_rationale:

select rec_id,to_char(attr5) from dba_advisor_rationale where execution_name = 'EXEC_24365'
and object_id = 19930
and rec_id > 0
order by rec_id
