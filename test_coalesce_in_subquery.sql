CREATE OR REPLACE FUNCTION test_coalesce_in_subquery
( p_inp nUMBER )
RETURN NUMBER
AS
BEGIN 
  DBMS_output.put_line ( systimestamp||': '|| $$plsql_unit||' inp:'||p_inp );
  RETURN  CASE WHEN p_inp > 2 THEN p_inp ELSE NULL END;
END;
/

show error 

set serveroutput on 

SELECT test_coalesce_in_subquery( level )
FROM dual
CONNECT BY level <= 4
;