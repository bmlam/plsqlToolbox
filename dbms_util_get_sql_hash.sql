CREATE OR REPLACE FUNCTION dbms_util_get_sql_hash
( string VARCHAR2 ) 
RETURN VARCHAR2
AS l_raw VARCHAR2(100); l_num nUMBER; l_pre10 nUMBER; 
BEGIN 
  l_num := dbms_utility.get_SQL_HASH( string, l_raw, l_pre10);
  RETURN ( to_char(l_num) ||' '||l_raw );
END;
/

show errors 
