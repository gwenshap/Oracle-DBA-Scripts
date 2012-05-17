rem
rem     Script:        index_efficiency.sql
rem     Author:        Jonathan Lewis
rem     Dated:         Sept 2003
rem     Purpose:       Example of how to check leaf block packing
rem
rem     Notes
rem     Last tested 9.2.0.4
rem
rem     Example of analyzing index entries per leaf block.
rem     The code examines index T1_I1 on table T1.
rem
rem     The index is on (v1, small_pad). Both columns appear
rem     the where clause with a not null test to avoid issues
rem     relating to indexes with completely nullable entries.
rem
rem     For a simple b-tree index, the first parameter to the
rem     sys_op_lbid() function has to be the object_id of the
rem     index.
rem
rem     The query will work with a sample clause
rem
rem     Check that the execution path is an index fast full scan
rem

column ind_id new_value m_ind_id
 
select
        object_id ind_id
from
        user_objects
where
        object_name = 'T1_I1'
;
 
break on report skip 1
compute sum of blocks on report
       
select
        rows_per_block,
        count(*) blocks
from (
        select
               /*+
                       cursor_sharing_exact
                       dynamic_sampling(0)
                       no_monitoring
                       no_expand
                       index_ffs(t1,t1_i1)
                       noparallel_index(t,t1_i1)
               */
               sys_op_lbid( &m_ind_id ,'L',t1.rowid) as block_id,
               count(*)                              as rows_per_block
        from
               t1
        --      t1 sample block (100)
        where
               v1 is not null
        or      small_pad is not null
        group by
               sys_op_lbid( &m_ind_id ,'L',t1.rowid)
)
group by rows_per_block
order by rows_per_block
;
