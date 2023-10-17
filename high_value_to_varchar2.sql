CREATE OR REPLACE FUNCTION high_value_to_varchar2 
( p_tab varchar2
 ,p_part varchar2
 )
RETURN VARCHAR2
AS
  l_return varchar2(4000 char);
BEGIN
  SELECT high_value INTO l_return
  FROM user_tab_partitions
  WHERE table_name = p_tab AND partition_name = p_part
  ;
  RETURN l_return;
RETURN null;
END;
/

show errors 
