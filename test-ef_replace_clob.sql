CREATE TABLE my_test_clob (key VARCHAR2(30), content CLOB )
;
GRANT SELECT ON my_test_clob TO LIONREP
;
TRUNCATE TABLE my_test_clob;

set serverout on timing on 



declare 
  cl1 clob;
  cl2 clob;
  lv_pos INTEGER;
  lv_found INTEGER;
begin 
    DELETE my_test_clob;
    cl1 := ' banana' || RPAD( ' ', 32767 - 10, ' ' )||'banana' ;
    cl1 := cl1 || RPAD( ' ', 32767, ' ' )||'bananabanana here comes the tail!' ;
    INSERT INTO my_test_clob VALUES ('src clob', cl1 );
    dbms_output.put_line ( 'len : '|| dbms_lob.getlength( cl1 ) );

    dbms_output.put_line ( '1st banana found at : '|| dbms_lob.instr( cl1, 'banana', offset=> 1 ) );
    dbms_output.put_line ( '2nd banana found at : '|| dbms_lob.instr( cl1, 'banana', offset=> 10 ) );
    dbms_output.put_line ( 'for comparison, 32k = '|| power(2, 15 ) );
    dbms_output.put_line ( '3rd banana found at : '|| dbms_lob.instr( cl1, 'banana', offset=> 32767+10 ) );

    dbms_output.put_line ( rpad( '*', 80, '*') );

    cl2 := sk_utility.ef_replace_clob( pi_src_clob=> cl1, pi_replace_from => 'banana', pi_replace_to=> 'apple' );
    INSERT INTO my_test_clob VALUES ('to apple', cl2 );
 
    dbms_output.put_line ( rpad( '*', 80, '*') );
   cl2 := sk_utility.ef_replace_clob( pi_src_clob=> cl1, pi_replace_from => 'banana', pi_replace_to=> 'papaya' );
   INSERT INTO my_test_clob VALUES ('to papaya', cl2 );

    dbms_output.put_line ( rpad( '*', 80, '*') );
   cl2 := sk_utility.ef_replace_clob( pi_src_clob=> cl1, pi_replace_from => 'banana', pi_replace_to=> 'coconuts' );
   INSERT INTO my_test_clob VALUES ('to coconuts', cl2 );

    COMMIT; 

  FOR rec IN ( 
    SELECT key, content, dbms_lob.getlength( content ) clob_len 
      ,substr( key, 4) as replace_to
    FROM my_test_clob
    WHERE key LIKE 'to %'
  ) LOOP
    dbms_output.put_line ( rpad( '*', 80, '*') );
    lv_pos := 1;
    WHILE lv_pos <= rec.clob_len 
    LOOP 
      lv_found := dbms_lob.instr( rec.content, rec.replace_to, offset=> lv_pos );
      dbms_output.put_line ( rec.replace_to||' found at : '|| lv_found );
      IF lv_found > 0
      THEN 
        lv_pos := lv_found + LENGTH( rec.replace_to );
      ELSE
        lv_pos := rec.clob_len + 1;
      END IF;
    END LOOP;
  END LOOP;
end;
/
