define sql_id=&1 
set trimspool on  
set headsep off heading off feedback OFF
set echo off verify off
set timing off
set linesize 4000  pages 20000 long 4000000 longchunksize 4000000 

column db_name new_val db_name

column spool_path_current new_val spool_path_current


SET SCAN ON DEFINE ON


SELECT sys_context( 'userenv', 'db_name' ) AS db_name
FROM dual
;
ALTER SESSION SET NLS_LANGUAGE=GERMAN;

host mkdir c:\temp\&db_name\sql


WITH prep_ AS 
( SELECT 'c:\temp\&db_name\sql' as base_folder
  FROM DUAL 
) 
SELECT base_folder||'\&sql_id..sql'  as  spool_path_current 
FROM prep_ 
;
PROMPT spool_path_current set to &spool_path_currentco

VAR sql_text CLOB

SET ECHO OFF VERIFY OFF FEEDBACK OFF  TERMOUT OFF TRIMSPOOL ON 

BEGIN
  FOR rec IN ( 
    WITH dist_pc_ AS (
      SELECT DISTINCT piece, sql_text text FROM v$sqltext WHERE sql_id = '&sql_id' 
    )
    SELECT count(1) OVER (PARTITION BY piece ) dupes_cnt 
      ,piece, text 
    FROM dist_pc_ 
    ORDER BY piece 
  ) LOOP
    IF rec.dupes_cnt > 1 THEN 
      RAISE_APPLICATION_ERROR( -20001, 'Piece '||rec.piece||' has '||rec.dupes_cnt||' versions!' );
    END IF;
    :sql_text := CASE WHEN rec.piece = 0 THEN rec.text ELSE :sql_text||rec.text END;
  END LOOP;
END;
/

spool &spool_path_current

print :sql_text

spool off 

SET ECHO ON VERIFY ON FEEDBACK ON lines 120 pages 50 TERMOUT ON 
