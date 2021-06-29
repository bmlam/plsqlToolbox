
set echo off scan on verify on 

set pages 300 lines 200  

define pi_sql_id=&1

select * from table ( dbms_xplan.display_cursor( sql_id=> '&pi_sql_id', CURSOR_CHILD_NO => null ) ); 


