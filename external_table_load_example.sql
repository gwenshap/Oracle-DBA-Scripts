drop table db.bm_tmp;

create table external_table
  (
str  varchar2(255),
id number(10) ,
toomuchdata clob,
genre_id number(10), -- can be null
time_stamp date
)
  organization external
  (
     type oracle_loader
     default directory slct_work_db_bm
     access parameters
     (
             records delimited by newline
                         CHARACTERSET AL32UTF8
             preprocessor exec_dir:'uncompress.sh'
                         badfile log_dir:'db_bm.bad'
                         logfile log_dir:'db_bm.log'
             fields terminated by '|'
             missing field values are null
             (
                     str,id,toomuchdata char(10000),genre_id,time_stamp char(19) date_format date 'yyyy-mm-dd hh24:mi:ss'))
                     location(
'db049.unl.gz',
'db050.unl.gz',
'db051.unl.gz',
'db052.unl.gz'
))
  parallel
  reject limit unlimited;

--select * from db.bm_tmp where rownum<=5;

truncate table real_table;

  alter session force parallel DML;

insert into /*+ PARALLEL(32) APPEND*/ real_table
select /*+ PARALLEL(32) */
 str,id,toomuchdata,decode(genre_id,'NULL',null,genre_id),time_stamp
from external_table;