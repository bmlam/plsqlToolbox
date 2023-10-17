-- footprint by partition of LOB columns of partitioned table b
WITH lob_data_parts AS ( 
  SELECT l.table_name
  , l.column_name lob_column 
  , l.segment_name lob_dat_ix_segment 
  , lp.partition_name table_partition 
  , s.partition_name segment_partition 
  , s.tablespace_name 
  , s.segment_type
  , s.bytes partition_size
  FROM user_lobs l 
  JOIN user_segments s ON s.segment_name = l.segment_name 
  JOIN user_lob_partitions lp ON lp.table_name = l.table_name AND lp. lob_partition_NAME = s.partition_name 
  ), lob_index_parts AS (
  SELECT l.table_name, l.column_name lob_column 
  , l.index_name AS lob_dat_ix_segment
  , lp.partition_name table_partition 
  , s.partition_name 
  , s.tablespace_name tablespace_name 
  , s.segment_type
  , s.bytes partition_size
  FROM user_lobs l 
  JOIN user_segments s ON s.segment_name = l.index_name 
  JOIN user_lob_partitions lp ON lp.table_name = l.table_name AND lp.LOB_INDPART_NAME = s.partition_name 
  ), ua AS (
SELECT *
from lob_data_parts
union all
select *
from lob_index_parts
UNION ALL 
SELECT l.table_name, l.column_name
, nULL as lob_dat_ix_segment
, tp.partition_name 
, tp.partition_name 
, s.tablespace_name 
, s.segment_type 
, s.bytes 
FROM user_lobs l 
JOIN user_tab_partitions tp ON l.table_name = tp.table_name 
JOIN user_segments s ON s.segment_name = l.table_name AND s.segment_type = 'TABLE PARTITION' AND s.partition_name = tp.partition_name 
), view1 AS (
  SELECT ua.* 
  , round( partition_size / 1024 /1024, 1 ) partition_mb
  , sum( round( partition_size / 1024 /1024, 1 ) ) over (partition by table_partition, tablespace_name ) part_foot_print_in_ts 
  , sum( round( partition_size / 1024 /1024, 1 ) ) over (partition by table_partition ) part_foot_print_in_all_ts 
  , ( SELECT sum ( bytes ) / 1024/1024 FROM dba_data_files df WHERE  df.tablespace_name = ua.tablespace_name ) AS ts_alloc_mb 
  FROM ua
  WHERE table_name = 'CMT_DOKUMENTE_LOB' 
    AND table_partition IN ( 'P_34', 'P_41' )
  ORDER BY lob_column, table_partition , segment_type 
) 
SELECT table_partition, tablespace_name
  , listagg( DISTINCT segment_type, ',') WITHIN GROUP (ORDER BY segment_type ) seg_types 
  , sum( partition_size ) /1024/1024 mb
  , ( SELECT sum ( bytes ) / 1024/1024 FROM dba_data_files df WHERE  df.tablespace_name = ua.tablespace_name ) AS ts_alloc_mb 
  FROM ua
  WHERE table_name = 'CMT_DOKUMENTE_LOB' 
    AND table_partition IN ( 'P_34', 'P_41' )
GROUP BY table_partition, tablespace_name
order BY table_partition, tablespace_name
  ;

-- work in progress - this versions tries to attribute CTX tables to the lob columns 
WITH with_lob_par_part_lob_name -- get LOB column's table which is partitioned, so also get the table partitions  
AS
( SELECT l.table_name lob_parent_table 
  , lp.partition_name lob_parent_tab_part
  , l.column_name lob_parent_lob_column
  , l.owner 
  , l.index_name lob_index_name 
  , lp.lob_indpart_name 
    FROM dba_lobs l 
    JOIN dba_lob_partitions lp ON ( lp.table_owner = l.owner AND lp.table_name = l.table_name AND lp.column_name = l.column_name )
), with_get_dr_par_ix -- if the CLOB column is OracleText indexed, get the index name and DR$ tables 
AS ( 
  SELECT t.table_name dr_table_name
  , regexp_replace( table_name, '^(DR\$)([A-Z0-9_]+)(.*)$', '\2' ) ctx_index_name 
  FROM user_tables t
  WHERE 1=1
    AND table_name LIKE 'DR$%'
  ), with_get_dr_par_tab AS (
  SELECT drp.*
  , ctx.idx_table business_table
  FROM with_get_dr_par_ix drp
  JOIN ctx_user_indexes ctx ON ctx.idx_name = drp.ctx_index_name 
  ),  main_ as ( 
SELECT s.owner, s.segment_name
, s.partition_name seg_partition_name
, s.segment_type, segment_subtype
, ix.index_type 
, drtab.business_table
, lobdata.table_name lob_of_table, lobdata.column_name lob_column
, lobdtp.partition_name table_partition_name
, lppln.lob_parent_table
, lppln.lob_parent_tab_part
, lppln.lob_parent_lob_column
, round(bytes /1024/1024) mb 
, lobdtp.lob_name
, ix.table_name ix_table_name, ix.index_name 
, ixp.partition_name ixp_partition_name 
FROM dba_segments s
-- for lobdata data column 
LEFT jOIN dba_lobs  lobdata ON lobdata.segment_name = s.segment_name AND lobdata.owner = s.owner 
LEFT JOIN dba_lob_partitions lobdtp ON ( lobdtp.table_name = lobdata.table_name AND lobdata.column_name = lobdtp.column_name And lobdata.owner = lobdtp.table_owner
   AND s.partition_name = lobdtp.lob_partition_name )
LEFT JOIN dba_indexes ix ON ix.owner = s.owner AND ix.index_name = s.segment_name 
LEFT JOIN dba_ind_partitions ixp ON ixp.index_owner = s.owner AND ix.index_name = s.segment_name AND s.partition_name = ixp.partition_name
LEFT JOIN with_get_dr_par_tab drtab ON ( s.segment_name = drtab.dr_table_name )
LEFT JOIN with_lob_par_part_lob_name lppln ON ( lppln.owner = s.owner AND lppln.lob_index_name = s.segment_name AND lppln.lob_indpart_name = s.partition_name )
WHERE 1=1
  AND s.owner = 'CMSOWNER'
--AND s.tablespace_name LIKE 'CMS_LOB%'
--AND s.segment_type lIKE 'INDEX%'
)
select * from main_  where 1=1 and lob_of_table is not null 
ORDER BY null
--lob_of_table, lob_column, table_partition_name 
;
