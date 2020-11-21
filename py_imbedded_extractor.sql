set trimspool on  
set headsep off heading off feedback OFF
set echo off verify off
set timing off
set linesize 4000  pages 20000 long 4000000 longchunksize 4000000 

column db_name new_val db_name

column spool_path_current new_val spool_path_current
column spool_path_history new_val spool_path_history

SET SCAN ON DEFINE ON

define v_spool_path=&1
define v_schema=&2
define v_object_type=&3
define v_object_name=&4
define v_ez_connect=&5

CONNECT &v_ez_connect

WHENEVER SQLERROR EXIT 

SELECT sys_context( 'userenv', 'db_name' ) AS db_name
FROM dual
;
ALTER SESSION SET NLS_LANGUAGE=GERMAN;


WITH prep_ AS 
( SELECT '&v_spool_path' as spool_path_current
  , UPPER( '&v_object_name' ) || '-'||'&db_name' as obj_name_and_db_name
  , CASE upper('&v_object_type') 
    WHEN 'PACKAGE_BODY' THEN '.pkb' 
    WHEN 'PACKAGE_SPEC' THEN '.pks' 
    WHEN 'TRIGGER' THEN '.trg' 
    WHEN 'TYPE_BODY' THEN '.tpb' 
    WHEN 'TYPE_SPEC' THEN '.tps' 
    WHEN 'VIEW' THEN '.vw' 
    ELSE '.sql' 
    END AS file_ext 
  FROM DUAL 
) 
SELECT spool_path_current as  spool_path_current 
FROM prep_ 
;


set termout off 

spool &spool_path_current

SELECT dbms_metadata.get_ddl( upper('&v_object_type'), upper( '&v_object_name' ), upper( '&v_schema' ) ) 
--INTO :v_code
FROM DUAL
;

spool off

EXIT