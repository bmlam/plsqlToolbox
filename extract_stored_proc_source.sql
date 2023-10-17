set trimspool on  
set headsep off heading off feedback OFF
set echo off verify off
set timing off
set linesize 4000  pages 20000 long 4000000 longchunksize 4000000 

column db_name new_val db_name

column spool_path_current new_val spool_path_current
column spool_path_history new_val spool_path_history

SET SCAN ON DEFINE ON

define v_object_type=&1
define v_object_name=&2
define v_schema=&3

SELECT sys_context( 'userenv', 'db_name' ) AS db_name
FROM dual
;
ALTER SESSION SET NLS_LANGUAGE=GERMAN;

host mkdir c:\temp\&db_name
host mkdir c:\temp\&db_name\keller 


WITH prep_ AS 
( SELECT 'c:\temp\&db_name\' as base_folder
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
SELECT base_folder||obj_name_and_db_name||file_ext as  spool_path_current 
     , base_folder||'keller\'||obj_name_and_db_name||'-'||TO_CHAR(sysdate, 'yyyymmdd_hh24mi')||file_ext  as  spool_path_history
FROM prep_ 
;

PROMPT spool_path_current set to &spool_path_current
PROMPT spool_path_history set to &spool_path_history

set termout off 

spool &spool_path_current

SELECT dbms_metadata.get_ddl( upper('&v_object_type'), upper( '&v_object_name' ), upper( '&v_schema' ) ) 
--INTO :v_code
FROM DUAL
;


spool off

set termout on feedback on heading on 

prompt Please for for output file &spool_path_current

HOST copy &spool_path_current &spool_path_history


rem PROMPT querying dba_OBJECTS 

rem set verify off echo off

-- DECLARE 
--   lv_found NUMBER;
-- BEGIN 
--   SELECT count(1) INTO lv_found
--   FROM all_objects 
--   WHERE owner = upper( '&v_schema' ) 
--     AND object_type = REGEXP_REPLACE( upper( '&v_object_type' ), '^([A-Z]+)(.*)$', '\1' ) 
--     AND object_name = upper( '&v_object_name' )
--   ;
--   IF lv_found = 0 THEN 
--     raise_application_error( -20001, 'object not found!' );
--   END IF;
-- END;  
-- /

set verify on echo on feedback on 

