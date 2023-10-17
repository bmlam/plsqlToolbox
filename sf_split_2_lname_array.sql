CREATE OR REPLACE FUNCTION sf_split_2_lname_array
( pi_str VARCHAR2
 ,pi_delim VARCHAR2 DEFAULT ','
 ,pi_trim_tokens BOOLEAN DEFAULT TRUE -- to remove whitespace around the comma separated tokens
) RETURN dbms_utility.lname_array 
AS
  lv_return  dbms_utility.lname_array;
  lv_count   NUMBER;
  lv_str     LONG;
BEGIN  
  lv_str := CASE WHEN pi_delim <> ',' THEN replace( pi_str, pi_delim, ',' ) ELSE pi_str END;
  --
  BEGIN 
    dbms_utility.comma_to_table (  lv_str
        , tablen => lv_count
        ,      tab => lv_return
    );
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20001 THEN
        RAISE_APPLICATION_ERROR( -20001, sqlerrm||chr(10)||'Note: tokens must not be a number or >= 30 chars' );
      ELSE  
        RAISE;
      END IF;
  END;
  IF pi_trim_tokens THEN 
    FOR i IN 1 .. lv_return.COUNT LOOP
      lv_return(i) := trim ( lv_return(i) );
    END LOOP;
  END IF;
  RETURN lv_return;
END;
/

SHOW ERRORS

-- test
declare 
  list dbms_utility.lname_array;
begin
  list := sf_split_2_lname_array('ab, xx, b123' );
  for i in 1 .. list.count loop
    dbms_output.put_line( 'token ' ||i||':'|| list(i) ||'<-');
  end loop;
end;
/
  
  
