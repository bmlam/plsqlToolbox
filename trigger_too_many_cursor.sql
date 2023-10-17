CREATE OR REPLACE TRIGGER trigger_too_many_cursor 
BEFORE UPDATE 
OF txs 
ON /*lam_*/cmt_dokumente_lob 
FOR EACH ROW 
DECLARE 

  procedure open_cur ( level integer )
  AS 
  CURSOR cur 
  IS
  SELECT *
  FROM dual
  ;
  BEGIN 
    IF level <= 999 THEN 
      OPEN cur;
      open_cur( level + 1);
    END IF;
  END open_cur;
BEGIN
    dbms_output.put_line( $$plsql_unit||':'||$$plsql_line||' '  );

    open_cur( 1 );
END;
/
show errors
