    select s.inst_id,s.sid,pxs.SERVER#,server_set,PGA_USED_MEM/1024/1024,PGA_ALLOC_MEM/1024/1024,PGA_FREEABLE_MEM/1024/1024,PGA_MAX_MEM/1024/1024
        from gV$PX_SESSION pxs
    join gv$session s on pxs.inst_id=s.inst_id and pxs.sid=s.sid
    join gv$process p on p.inst_id=s.inst_id and p.addr=s.paddr
    where degree > 4
    --order by inst_id,server#
   order by PGA_USED_MEM;

--select * from gv$temporary_lobs;

exit;