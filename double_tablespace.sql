-- Script written for a case where data was loaded rapidly and without prior notice
-- DBAs got tired of adding more space every few hours
-- But there was a global company policy against auto-extend
-- So we decided that tablespace size should double on every resize
-- To minimize the number of resizes DBAs had to do.

declare
  new_size number :=0;
  file_to_grow dba_data_files.file_name%TYPE := null;
  last_file dba_data_files.file_name%TYPE := null;
  l_instance_name v$instance.instance_name%TYPE;
begin
  FOR tbs_rec in
    (SELECT a.TABLESPACE_NAME tbs_name,
    a.BYTES bytes_used,
    b.BYTES bytes_free,
    b.largest,
    round(((a.BYTES-b.BYTES)/a.BYTES)*100,2) percent_used
    from
    (
    select TABLESPACE_NAME,
    sum(BYTES) BYTES
    from dba_data_files
    group by TABLESPACE_NAME
    )
    a join 
    (
    select TABLESPACE_NAME,
    sum(BYTES) BYTES ,
    max(BYTES) largest
    from dba_free_space
    group by TABLESPACE_NAME
    )
    b  on a.TABLESPACE_NAME=b.TABLESPACE_NAME
    where 1=1
    and round(((a.BYTES-b.BYTES)/a.BYTES)*100,2)>90
    and a.tablespace_name not like 'UNDO%'
    order by ((a.BYTES-b.BYTES)/a.BYTES) desc)
  LOOP
    dbms_output.put_line('Need more space in: ' || tbs_rec.tbs_name);
    for file_rec in
      (select file_name,bytes from dba_data_files where tablespace_name=tbs_rec.tbs_name order by file_id)
    LOOP
      dbms_output.put_line('found file ' || file_rec.file_name || ' with ' || file_rec.bytes || ' bytes size'); 
      if file_rec.bytes < 5000000000 /*5G*/ then
        new_size := file_rec.bytes*2; /*double file size*/
        file_to_grow := file_rec.file_name;
        exit; /* if found file we can grow, no need to check more files */
      elsif file_rec.bytes < 20000000000 /*20G*/ then
        new_size := file_rec.bytes+10000000000; /*add 10G*/
        file_to_grow := file_rec.file_name;
        exit; /* if found file we can grow, no need to check more files */
      else
        /* we need to keep track of existing files in case we need to add more */
        last_file := file_rec.file_name;
      end if;
    END LOOP;
    if file_to_grow is not null then
    /* grow file*/
    dbms_output.put_line('ALTER DATABASE DATAFILE ''' || file_to_grow || ''' RESIZE ' || new_size);
    else
    null;
    /* add new file */
    select instance_name into l_instance_name from v$instance;
    dbms_output.put_line(to_number(REGEXP_REPLACE(last_file,'.*_(\d+).dbf','\1'))+1);
    dbms_output.put_line('alter tablespace ' ||  tbs_rec.tbs_name || ' add datafile /u05/oradata/' ||  l_instance_name || '/' || tbs_rec.tbs_name ||'_' || to_char(to_number(REGEXP_REPLACE(last_file,'.*_(\d+).dbf','\1'))+1) || '.dbf size 4M autoextend off;');
    end if;
  END LOOP;
end;