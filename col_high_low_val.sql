-- col_stats
-- Martin Widlake mdw 21/03/2003
-- MDW 11/12/09 enhanced to include more translations of low_value/high_value
-- pilfered from Gary Myers blog
col owner        form a6 word wrap
col table_name   form a15 word wrap
col column_name  form a22 word wrap
col data_type    form a12
col M            form a1
col num_vals     form 99999,999
col dnsty        form 0.9999
col num_nulls    form 99999,999
col low_v        form a18
col hi_v         form a18
col data_type    form a10
set lines 110
break on owner nodup on table_name nodup
spool col_stats.lst
select --owner
--      ,table_name
      column_name
      ,data_type
      ,decode (nullable,'N','Y','N')  M
      ,num_distinct num_vals
      ,num_nulls
      ,density dnsty
,decode(data_type
  ,'NUMBER'       ,to_char(utl_raw.cast_to_number(low_value))
  ,'VARCHAR2'     ,to_char(utl_raw.cast_to_varchar2(low_value))
  ,'NVARCHAR2'    ,to_char(utl_raw.cast_to_nvarchar2(low_value))
  ,'BINARY_DOUBLE',to_char(utl_raw.cast_to_binary_double(low_value))
  ,'BINARY_FLOAT' ,to_char(utl_raw.cast_to_binary_float(low_value))
  ,'DATE',to_char(1780+to_number(substr(low_value,1,2),'XX')
         +to_number(substr(low_value,3,2),'XX'))||'-'
       ||to_number(substr(low_value,5,2),'XX')||'-'
       ||to_number(substr(low_value,7,2),'XX')||' '
       ||(to_number(substr(low_value,9,2),'XX')-1)||':'
       ||(to_number(substr(low_value,11,2),'XX')-1)||':'
       ||(to_number(substr(low_value,13,2),'XX')-1)
,  low_value
       ) low_v
,decode(data_type
  ,'NUMBER'       ,to_char(utl_raw.cast_to_number(high_value))
  ,'VARCHAR2'     ,to_char(utl_raw.cast_to_varchar2(high_value))
  ,'NVARCHAR2'    ,to_char(utl_raw.cast_to_nvarchar2(high_value))
  ,'BINARY_DOUBLE',to_char(utl_raw.cast_to_binary_double(high_value))
  ,'BINARY_FLOAT' ,to_char(utl_raw.cast_to_binary_float(high_value))
  ,'DATE',to_char(1780+to_number(substr(high_value,1,2),'XX')
         +to_number(substr(high_value,3,2),'XX'))||'-'
       ||to_number(substr(high_value,5,2),'XX')||'-'
       ||to_number(substr(high_value,7,2),'XX')||' '
       ||(to_number(substr(high_value,9,2),'XX')-1)||':'
       ||(to_number(substr(high_value,11,2),'XX')-1)||':'
       ||(to_number(substr(high_value,13,2),'XX')-1)
,  high_value
       ) hi_v
from dba_tab_columns
where owner      like upper('&tab_own')
and   table_name like upper(nvl('&tab_name','WHOOPS')||'%')
ORDER BY owner,table_name,COLUMN_ID
/
clear colu
spool off
clear breaks