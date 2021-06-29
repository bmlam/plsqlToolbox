--CREATE global TEMPORARY TABLE tt_clob ( owner varchar2(30), type varchar2(30), name varchar2(30), text clob ) on COMMIT preserve rows;

set trimspool on  
set headsep off heading off feedback OFF
set echo off verify off
set timing off
set linesize 4000  pages 20000 long 4000000 longchunksize 4000000 

column db_name new_val db_name

column spool_path_current new_val spool_path_current
column spool_path_history new_val spool_path_history

REM CREATE GLOBAL TEMPORARY TABLE tt_clob ( text clob ) on commit preserve rows  ;

SET SCAN ON DEFINE ON

define lv_object_type=&1
define lv_object_name=&2
define lv_schema=&3

SELECT sys_context( 'userenv', 'db_name' ) AS db_name
FROM dual
;
ALTER SESSION SET NLS_LANGUAGE=GERMAN;

host mkdir c:\temp\&db_name
host mkdir c:\temp\&db_name\keller 


WITH prep_ AS 
( SELECT 'c:\temp\&db_name\' as base_folder
  , UPPER( '&lv_object_name' ) || '-'||'&db_name' as obj_name_and_db_name
  , CASE upper('&lv_object_type') 
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


SET ECHO OFF VERIFY OFF 








DECLARE 
  lv_schema VARCHAR2(30) :=  UPPER('&lv_schema');
  lv_object_type VARCHAR2(30) :=  UPPER('&lv_object_type');
  lv_type_to_filter  VARCHAR2(30) ;
  lv_object_name VARCHAR2(30) :=  UPPER('&lv_object_name');
  lv_clob  CLOB := 'CREATE OR REPLACE ';
  lv_text  LONG;
BEGIN
  lv_type_to_filter := 
    CASE lv_object_type 
    WHEN 'PACKAGE_SPEC' THEN 'PACKAGE'
    WHEN 'PACKAGE_BODY' THEN 'PACKAGE BODY'
    WHEN 'TYPE_SPEC' THEN 'TYPE'
    WHEN 'TYPE_BODY' THEN 'TYPE BODY'
    ELSE lv_object_type
    END;

  dbms_output.put_line ( lv_schema||'.'||lv_object_name||'.'||lv_object_type );
  EXECUTE IMMEDIATE 'truncate  table tt_clob';
  FOR rec IN (
    SELECT line, text
    FROM dba_source
    WHERE owner = lv_schema
      AND type  = lv_type_to_filter 
      AND name  = lv_object_name
    ORDER BY line 
  ) LOOP
    lv_text := rec.text; 
    dbms_lob.append( lv_clob, lv_text );
    -- dbms_OUTPUT.put_line( 'Ln'||$$plsql_line||': '||lv_offset );
    -- IF mod(rec.line, 13) = 1 THEN       dbms_output.put_line( rec.text );    END IF;
  END LOOP;
  INSERT INTO tt_clob( text ) VALUES ( lv_clob );
  COMMIT;
END;
/

set termout off 

spool &spool_path_current


SELECT text FROM tt_clob ;

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
--   WHERE owner = upper( '&lv_schema' ) 
--     AND object_type = REGEXP_REPLACE( upper( '&lv_object_type' ), '^([A-Z]+)(.*)$', '\1' ) 
--     AND object_name = upper( '&lv_object_name' )
--   ;
--   IF lv_found = 0 THEN 
--     raise_application_error( -20001, 'object not found!' );
--   END IF;
-- END;  
-- /

set verify on echo on feedback on 

