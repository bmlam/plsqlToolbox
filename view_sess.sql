sta C:\projects\sandbox\toolbox\get_sql_monitor_report.sql 38r861a8hp45c 1607 41492 2

alter session set nls_date_format = 'yyyymmdd hh24:mi:ss';

set lines 180 pages 100 echo on 
col sql_text format a60
col event format a30
col last_load_time format a20
col child forma 999 
col inst forma 999 

select * from v$instance
;

--    
-- main on session 
--
set lines 250 pages 100
col username format a20
col event format a32
col modu format a45
col status format a10
col action format a30
col sql_id format a20
col inst_id format 99

select to_char(sysdate, 'hh24:mi') now
, lpad(sid, 4, ' ')||'#'||serial#
||'@'||inst_id 
sid_inst
, round(  (sysdate - logon_time) * 1440 , 1 )sess_mins
, lpad(final_blocking_session, 4, ' ')||'@'||final_blocking_instance fin_blocker
,s.username, osuser
,logon_time ses_sta
, event, status sta
--, s.inst_id 
--, program prg
--, osuser osu
,substr(module,1,40) modu
,sql_id ||':'||sql_child_number sq_id
, substr(s.action,1,50) action 
,sql_address,saddr ses_addr
--,blocking_session_status blk_ses_sta
, s.blocking_session blocker
, (select qcsid from gv$px_session px where px.sid = s.sid and px.inst_id = s.inst_id ) parent_sid 
, s.* 
from gv$session s
where 1=1
  and s.username in ( 'BZ_60BAT', 'IMEXAPPx', 'IMPORT_IMEX', 'INVSIMx', 'LICENSING', 'LIONREP', 'MAINT_WAAS', 'PARTNERx', 'DATARC' )
----  and s.module like   'licensing.sk_licensing.ep_get_licensing%' 
  and s.status = 'ACTIVE'   
   and username not in ( 'SYS' )
--   and s.sid = 66
--  and regexp_like( module , 'sk_invoice_ginf', 'i' )
--  and s.sid = 938
--  and logon_time < trunc( sysdate )-20
--  and logon_time < trunc( sysdate )-1
-- and trunc( logon_time, 'dd' ) = date'2020-03-12'
--  and s.inst_id = 2
  order by null--
--  , modu
  , logon_time 
  ,inst_id desc, sid
  -- , logon_time, case when s.username = 'LIONREP' then 9 else 1 end
;
select * from gv$px_session
;
select * from dba_scheduler_jobs where owner = 'xx'
;
-- scan current SQL . For SQLPLUS formatting, see top of file 
select s.inst_id, s.logon_time,
s.sid, q.sql_id, q.exact_matching_signature--, q.force_matching_signature
, child_number, executions,rows_processed,fetches, last_load_time,substr(sql_text,1,60) sql_head 
, s.event, row_wait_obj#
, sql_text
,q.*
from gv$sql q left join gv$session s on (s.inst_id=q.inst_id and q.address=s.sql_address and s.inst_id= q.inst_id ) 
where 1=1 
--  and s.sid in ( 322, 916 ) and s.inst_id = 1
  and q.sql_id in ( '38r861a8hp45c', 'xx' ) -- on v_tx view 
order by q.last_load_time desc fetch first 5 rows only
;

--  BIND variable values 
select name, position, datatype_string, value_string from v$sql_bind_capture where sql_id = '6xkh01t2cynma'
;
-- execution plan 
select * from table( dbms_xplan.display_cursor( sql_id => '7n16zr29v4aqu', format=> 'ALL' , CURSOR_CHILD_NO => 3
) )
;
select * from dba_sql_plan_baselines where signature=16375286710734935547
;
select child_number, name, position, datatype_string, value_string from v$sql_bind_capture where sql_id = '7w901148nh1sg' 
--and child_number=1
;
-- monitor 
SELECT DBMS_SQLTUNE.report_sql_monitor(
  --sql_id       => '247v4wzgyu9r2'
  session_id => 798
  , inst_id => 1
  ,type         => 'TEXT'
  ,report_level => 'ALL') AS report
FROM dual
;
select username, osuser, status
--, program
, max(sid), count(1) 
from Gv$session 
where 1=1
--and username not in ( 'SYS' ) 
--  and osuser like 'blam%'
--  and username like 'LICEN%'
  and status = 'ACTIVE' 
group by rollup( username, osuser, status )
  order by count(1) desc 
;
select systimestamp, sid, sql_id, logon_time from gv$session where username = 'IMPORT_IMEX' and status = 'ACTIVE' and osuser = 'ORACLE';

-- execution stats 
select child_number chdno, address, sql_id, executions exec#, end_of_fetch_count completed#, rows_processed row_proc, s.* 
from gv$sql  s
where 1=1
-- and hash_value = 1432471311
--  AND s.address = '000000D8DB4B0C48'
 and sql_id = '38r861a8hp45c'
;
set lines 140 pages 100
col localtimestamp form a30
col name form a36
col value form 999g999g999g999
select localtimestamp, va.statistic#, na.name, va.value from gv$sesstat va join v$statname na ON na.statistic# = va.statistic# where va.inst_id = 1   and va.sid = 1530 and va.statistic# in (31,52,139,159,287,548,945) order by 2
;
-- full sql text 
select 
 listagg( sql_text) within group ( order by piece ) full_sql 
FROM ( 
    select distinct  sql_text    , piece 
    from gv$sqltext
where 1=1
  and sql_id= '38r861a8hp45c'
--  and piece > 60
) d1 
order by piece
  ;
select t.*      
, row_number() over (partition by inst_id, sql_id, address, hash_value, command_type order by piece) dedupe    from gv$sqltext t where 1=1   and sql_id= 'agykwd6wfux6m'
;
select * 
from v$lock where sid = 857
;
select * from dba_hist_sql_plan where sql_id = 'brjna05aq3jsg'
;
select sh.begin_interval_time, st.* 
from dba_hist_sqlstat st
join dba_hist_snapshot sh on sh.snap_id = st.snap_id
where sql_id = 'a4fsnwgjj2aa9'
--  and sh.sample_time > sysdate - 1/48
order by st.snap_id desc 
;
select * from dba_hist_snapshot
;
select null " "
--round( elapsed_seconds/(time_remaining+elapsed_seconds) *100,2) done_pct_est 
, lo.* 
from gv$session_longops lo
join gv$session s on (s.inst_id = lo.inst_id and s.sid = lo.sid and s.serial# = lo.serial# )
where 1=1 
--and sid = 40 
--  and s.username in (  'BZ_60BAT', 'LICENSING', 'LIONREP', 'DATARC'  )
  and s.inst_id = 2 
   and s.sid in ( 213 ) 
order by last_update_time desc
;
-- temp usage 
with temp_usg_seg_ as ( 
    select sql_id_tempseg, tablespace ts_name, sum( blocks ) *8/1024 mb , sum(extents) ext#
    from gv$tempseg_usage
    where session_addr = '00000019C07A6E08' -- from v$session.saddr
    group by sql_id_tempseg, tablespace 
)
select tu.*, q.sql_text 
from  temp_usg_seg_ tu join v$sql  q on q.sql_id = tu.sql_id_tempseg 
where 1=1
;
select * from dba_tablespaces where tablespace_name = 'TEMP'
;
-- locks 
select
   o.owner,
   o.object_name,
   o.object_type,
   s.sid,
   s.serial#,
   s.status,
   s.osuser,
   s.machine
from v$locked_object l 
join v$session    s ON l.session_id = s.sid
join dba_objects  o ON o.object_id = l.object_id
where o.object_name = 'xx'
;

select se.logon_time, xa.used_urec urec /*, xa.* */from gv$transaction xa join gv$session se on xa.addr =  se.taddr AND xa.inst_id=se.inst_id where 1=1  and se.username = 'IMPORT_IMEX' 
;

-- "jobs"
select substr( pd.program_unit, -30 ) prog_unit_tail, p.creation_dt cre_dt, p.* 
from process.t_processes p join t_process_definitions pd on pd.id = p.prcdef_id
where groupname = 'xx'  
-- and to_char( start_date, 'yyyy.mm.dd' ) = '2018.06.22' 
  and p.id in ( 694222, 694223, 694229 )
order by p.creation_dt  desc
;
--from Fernanod:
select snap_id snpid, sample_id, cast( sample_time as date)smp_time, usecs_per_row, session_id, sql_id, a.* 
from DBA_HIST_ACTIVE_SESS_HISTORY a where A.DBID = (select dbid from v$database ) 
and session_id = 1530
and sql_id = '7n16zr29v4aqu'
  and sample_time > sysdate- 5
order by snap_id desc
;



select * from v$database;
select * from v$instance;


select * from dba_parallel_execute_tasks
;
select * from dba_parallel_execute_chunks
;