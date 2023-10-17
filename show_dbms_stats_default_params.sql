set echo off feedback off pages 50 lines 82

col param format a40 
col value format a40 

var NO_INVALIDATE VARCHAR2 (10) 
DECLARE  b boolean; 
begin b := dbms_stats.to_no_invalidate_type ( dbms_stats.get_param('NO_INVALIDATE')) ; 
  :NO_INVALIDATE := CASE WHEN b THEN 'TRUE' WHEN NOT b THEN 'FALSE' ELSE 'NULL' END;
end;
/

-- var AUTO_CASCADE VARCHAR2 (10) 
-- DECLARE  b boolean; 
-- begin b := to_cascade_type( dbms_stats.AUTO_CASCADE ); 
--   :AUTO_CASCADE := CASE WHEN b THEN 'TRUE' WHEN NOT b THEN 'FALSE' ELSE 'NULL' END;
-- end;
-- /

var AUTO_SAMPLE_SIZE VARCHAR2 (40) 
begin :AUTO_SAMPLE_SIZE :=  dbms_stats.AUTO_SAMPLE_SIZE ; 
end;
/


-- var CASCADE VARCHAR2 (10) 
-- DECLARE  b boolean; 
-- begin b := dbms_stats.to_cascade_type( dbms_stats.get_param('CASCADE') ) ; 
--   :NO_INVALIDATE := CASE WHEN b THEN 'TRUE' WHEN NOT b THEN 'FALSE' ELSE 'NULL' END;
-- end;
-- /
-- 
SELECT * FROM ( 
SELECT 'xxx' param, 'yyy' as value  FROM dual WHERE 1=0 
-- UNION ALL SELECT 'ESTIMATE_PERCENT' , :ESTIMATE_PERCENT FROM dual
UNION ALL SELECT 'GRANULARITY' param, dbms_stats.GET_PARAM('GRANULARITY') FROM dual
UNION ALL SELECT 'CASCADE' param, dbms_stats.GET_PARAM('CASCADE') FROM dual
UNION ALL SELECT 'ESTIMATE_PERCENT' param, dbms_stats.GET_PARAM('ESTIMATE_PERCENT') FROM dual
UNION ALL SELECT 'NO_INVALIDATE' param, 'BOOLEAN '||:NO_INVALIDATE FROM dual
UNION ALL SELECT 'AUTO_SAMPLE_SIZE' param, :AUTO_SAMPLE_SIZE FROM dual
-- UNION ALL SELECT 'AUTO_CASCADE' param, :AUTO_CASCADE FROM dual
) ORDER BY param
;
 
col text format a120

-- source:
select text from dba_source where owner = 'SYS' and name = 'DBMS_STATS' and type = 'PACKAGE'
 and LOWER( text ) like '% constant %' AND NOT text like '--%'
;
