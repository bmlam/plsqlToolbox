set serveroutput  on 









declare 
  x boolean := null;
begin 
  if  x THEN 
    dbms_output.put_line( $$plsql_line );
  else 
    dbms_output.put_line( $$plsql_line );
  end if;
  if  x OR TRUE THEN 
    dbms_output.put_line( $$plsql_line );
  else 
    dbms_output.put_line( $$plsql_line );
  end if;
  if  x AND false THEN 
    dbms_output.put_line( $$plsql_line );
  else 
    dbms_output.put_line( $$plsql_line );
  end if;
  if  true and x THEN 
    dbms_output.put_line( $$plsql_line );
  else 
    dbms_output.put_line( $$plsql_line );
  end if;
END ;
/