set serverout on timing on 
declare cl clob;
begin 
    cl := ' banana' || RPAD( ' ', 32767 - 10, ' ' )||'banana' ;
    cl := cl || RPAD( ' ', 32767, ' ' )||'banana' ;
    dbms_output.put_line ( 'len : '|| dbms_lob.getlength( cl ) );

    dbms_output.put_line ( '1st banane found at : '|| dbms_lob.instr( cl, 'banana', 1 ) );
    dbms_output.put_line ( '2nd banane found at : '|| dbms_lob.instr( cl, 'banana', 10 ) );
    dbms_output.put_line ( 'for comparison, 32k = '|| power(2, 15 ) );
    dbms_output.put_line ( '3rd banane found at : '|| dbms_lob.instr( cl, 'banana', 32767+10 ) );
end;
/
