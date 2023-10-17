--fill_markdown_table.sql
set lines 200 pages 500  trimspool on 

with signature_ as ( 
     SELECT listagg( argument_name||'=> '||value, ',' ) WITHIN GROUP (ORDER BY argument_name) as signa
            , job_name , owner 
     FROM dba_SCHEDULER_job_ARGS 
     GROUP BY job_name, owner 
), magic_strings AS ( 
  SELECT chr(10) as nl, '\\'||chr(10) colend, '|' as colbeg 
  FROM dual
)  
select 
--j.job_name  ,   substr( s.signa, 14) ,
   colbeg||replace( j.job_name, '_', '~_' )|| colend 
    || colbeg||replace( substr( s.signa,14) , '_', '~_' )|| colend 
    || colbeg||' '|| colend 
    markdown 
from dba_scheduler_jobs j
CROSS JOIN magic_strings m 
LEFT JOIN dba_scheduler_programs spr ON spr.program_name = j.program_name AND spr.owner = j.owner
LEFT JOIN signature_ s ON s.job_name = j.job_name AND s.owner = j.owner 
where 1=1
 AND j.owner IN ( 'VBSOWNER', 'xVIXOWNER' , 'xCMSOWNER' )
  AND spr.program_action LIKE 'vbs$task%'
order by j.job_name 
--FETCH FIRST 4 rows only 
;