SET serverout ON 

DECLARE 
  TYPE list_type_pattern IS TABLE OF user_users%ROWTYPE;
  v_list list_type_pattern;
  v_ix NUMBER;
BEGIN 
  v_list := list_type_pattern();
  FOR i IN 1 .. 3 
  LOOP
    v_list.extend();
    v_list( v_list.COUNT).username := 'User'||to_char(i);
  END LOOP;
  dbms_output.put_line ( 'Ln'||$$plsql_line||': '||v_list.count );
  
  v_list.delete(2);
  
  v_ix := v_list.first;
  WHILE v_ix IS NOT NULL 
  LOOP
    dbms_output.put_line ( 'Ln'||$$plsql_line||': elem '||v_ix||' is '||v_list(v_ix).username );
    v_ix := v_list.next( v_ix);
  END LOOP;
END;
/

/* result:
Ln12: 3
Ln19: elem 1 is User1
Ln19: elem 3 is User3
*/ 
