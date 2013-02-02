SELECT
	sql_exec_id,
	plan_line_id id
  	, LPAD(' ',plan_depth) || plan_operation
		||' '||plan_options||' '
  		||plan_object_name operation
  	, ROUND(physical_read_bytes   /1048576) phyrd_mb
  	, ROUND(io_interconnect_bytes /1048576) ret_mb
    , (1-(io_interconnect_bytes/NULLIF(physical_read_bytes,0)))*100 "SAVING%"
FROM
	v$sql_plan_monitor
WHERE
     sql_id = '9n2fg7abbcfyx'