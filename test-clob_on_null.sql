set serveroutput on 









declare 
  v_lob_no_init CLOB;
  v_lob_init CLOB := '';
  v_lob_empty CLOB := empty_clob;
BEGIN 
  IF v_lob_init IS NULL then
    dbms_output.put_line( 'Ln'||$$plsql_line );
  END IF;  
  IF v_lob_no_init IS NULL then
    dbms_output.put_line( 'Ln'||$$plsql_line );
  END IF;
  IF v_lob_empty IS NULL then
    dbms_output.put_line( 'Ln'||$$plsql_line );
  END IF;
    dbms_output.put_line( 'Ln'||$$plsql_line ||' v_lob_no_init len:' ||dbms_lob.getlength(v_lob_no_init));
    dbms_output.put_line( 'Ln'||$$plsql_line ||' v_lob_init len:' ||dbms_lob.getlength(v_lob_init));
    dbms_output.put_line( 'Ln'||$$plsql_line ||' v_lob_empty len:' ||dbms_lob.getlength(v_lob_empty));
END;
/