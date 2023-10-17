define pi_sql_id=&1
define pi_sess_id=&2
define pi_serial=&3
define pi_inst_id=&4

set trimspool on  
set headsep off heading off feedback OFF
set echo off verify off
set timing off
set linesize 4000  pages 20000 long 4000000 longchunksize 4000000 

VARIABLE serial_nr VARCHAR2(10)

column sub_dir new_val sub_dir
column serial_nr new_val serial_nr
column spool_path new_val spool_path

SET SCAN ON DEFINE ON


SELECT 'c:\temp\sql_monitor_report-'||sys_context( 'userenv', 'db_name' ) AS sub_dir
  , TRIM(serial#) as serial_nr 
FROM gv$session
WHERE inst_id = &pi_inst_id 
 AND sid = &pi_sess_id
;

host mkdir &sub_dir

SELECT REPLACE('&sub_dir\SQL_&pi_sql_id-SESS_&pi_sess_id'||'.html' , '')  as spool_path
FROM dual
;


PROMPT spool_path set to &spool_path

set termout off echo off feedback off 

spool &spool_path

SELECT DBMS_SQLTUNE.report_sql_monitor(
  sql_id       => '&pi_sql_id'
  ,session_id => &pi_sess_id
  ,inst_id => &pi_inst_id
  ,type         => 'HTML'
  ,report_level => 'ALL'
  --, SESSION_SERIAL  => case &pi_serial when -1 then null else &pi_serial end             -- NUMBER
  --, SQL_EXEC_START => to_date( '2020.09.16 12:00', 'yyyy.mm.dd hh24:mi')              -- DATE
  -- , SQL_EXEC_ID                 -- NUMBER
  -- , INST_ID                     -- NUMBER
  -- , START_TIME_FILTER           -- DATE
  -- , END_TIME_FILTER             -- DATE
  -- , INSTANCE_ID_FILTER          -- NUMBER
  -- , PARALLEL_FILTER             -- VARCHAR2
  -- , PLAN_LINE_FILTER            -- NUMBER
  -- , EVENT_DETAIL                -- VARCHAR2
  -- , BUCKET_MAX_COUNT            -- NUMBER
  -- , BUCKET_INTERVAL             -- NUMBER
  -- , BASE_PATH                   -- VARCHAR2
  -- , LAST_REFRESH_TIME           -- DATE
  -- , REPORT_LEVEL                -- VARCHAR2
  -- , AUTO_REFRESH                -- NUMBER
  -- , SQL_PLAN_HASH_VALUE         -- NUMBER
  -- , DBOP_NAME                   -- VARCHAR2
  -- , DBOP_EXEC_ID                -- NUMBER
  -- , CON_NAME                    -- VARCHAR2
) AS report
FROM dual;


spool off

-- On 9.Nov.2020 got this: 
--ORA-12850: Could not allocate slaves on all specified instances: 2 needed, 0 allocated
--ORA-06512: at "SYS.DBMS_SQLTUNE", line 18334
--ORA-06512: at "SYS.DBMS_SQLTUNE", line 13676
--ORA-06512: at "SYS.DBMS_SQLTUNE", line 18430
--ORA-06512: at "SYS.DBMS_SQLTUNE", line 18761
--ORA-06512: at line 1
--12850. 00000 -  "Could not allocate slaves on all specified instances: %s needed, %s allocated"
--*Cause:    When executing a query on a gv$ fixed view, one or more
--           instances failed to allocate a slave to process query.
--*Action:   Check trace output for instances on which slaves failed to start.
--           GV$ query can only proceed if slaves can be allocated on all
--           instances.

set termout on feedback on heading on 

prompt Please check output file &spool_path


