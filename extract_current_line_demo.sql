rem A logging framework normally would expose some API methods to take a logging message for writing into a database table.
rem Along with the logging message, the framework would be well-advised to store in the table at which line the exposed API
rem was called. 
rem This script demonstrate a method to extract the this line of number

create or replace PACKAGE test_pkg_a IS
  PROCEDURE the_proc ( p_text VARCHAR2 )   ;
end;
/ 
show errors

create or replace PACKAGE BODY test_pkg_a IS

 PROCEDURE the_proc ( p_text VARCHAR2
 ) 
  IS
	l_dummy_prc_id integer;
	l_stack_text VARCHAR2(4000);
	l_stack_line      VARCHAR2(200);
	l_stack_line_bak  VARCHAR2(200);
	l_logging_line VARCHAR2(200);
	l_log_prolog VARCHAR2(200);
	lc_loop_max_cnt INTEGER := 9;
	l_loop_ix INTEGER := 1;
  l_found_the_proc BOOLEAN := FALSE;
	--
	function next_line_of_stack( pi_reverse_seq INTEGER ) 
	RETURN VARCHAR2
	AS
		l_return VARCHAR2(1000) ;
		l_nl_pos_left  INTEGER;
		l_nl_pos_right INTEGER;
		l_line_len  INTEGER;
	BEGIN
		dbms_output.put_line( $$plsql_line||' pi_reverse_seq: '||pi_reverse_seq);
		l_nl_pos_left  := INSTR( l_stack_text, CHR(10), -1, pi_reverse_seq + 1); -- search from end for the n. occurrence 
		l_nl_pos_right := INSTR( l_stack_text, CHR(10), -1, pi_reverse_seq ); -- search from end for the n. occurrence 
		dbms_output.put_line( $$plsql_line||': '||l_nl_pos_left||' '||l_nl_pos_right );
		IF l_nl_pos_left > 0 AND  l_nl_pos_right > 0 THEN
			l_line_len := l_nl_pos_right - l_nl_pos_left;
			l_return := SUBSTR(l_stack_text, l_nl_pos_left + 1, l_line_len);
		END IF;
		dbms_output.put_line( $$plsql_line||' l_return: '||l_return);
		RETURN l_return;
	END next_line_of_stack;

  BEGIN
    dbms_output.put_line( '****************  p_text: '||p_text );
    l_stack_text := DBMS_UTILITY.FORMAT_CALL_STACK();
    dbms_output.put_line( '*** stack : '||l_stack_text  );
    WHILE l_loop_ix <= lc_loop_max_cnt  AND NOT l_found_the_proc LOOP
      l_stack_line := next_line_of_stack( pi_reverse_seq => l_loop_ix );
      dbms_output.put_line( $$plsql_line||': ix '||l_loop_ix||': line'||l_stack_line);
      IF  INSTR( l_stack_line, $$PLSQL_UNIT ) > 0  AND INSTR( l_stack_line, 'THE_PROC' ) > 0 
      THEN 
        dbms_output.put_line( '************** found myself at '||l_loop_ix);
        l_found_the_proc := TRUE;
        EXIT;
        -- extract object name 
      END IF;
      l_loop_ix := l_loop_ix + 1;
      l_stack_line_bak := l_stack_line;
    END LOOP;
    l_logging_line :=  regexp_replace( l_stack_line_bak, '^0x([a-f[:digit:]]+) +([[:digit:]]+) +([[:alnum:]_\. ]+)', '\3:\2');Ø
    dbms_output.put_line( '************** Call stack line: '||l_logging_line);

  END the_proc;

END;
/

SHOW ERRORS





create or replace procedure test_caller AS 
BEGIN
  test_pkg_a.the_proc( 'first call');
  null;
  test_pkg_a.the_proc( 'second call');
END;
/
show errors
  
prompt more complicated example

create or replace package test_pkg_b AS
  procedure ext_p1;
  procedure ext_p2;
end;
/

show errors  

create or replace package body test_pkg_b
as
  procedure int_p as begin test_pkg_a.the_proc( 'called from INT_P'); end;
  
  procedure ext_p1 as begin int_p; end;

  procedure ext_p2 as begin test_pkg_a.the_proc( 'called from EXT_P2'); end;
end;
/

show errors  

set serveroutput on 
  
exec test_caller

exec test_pkg_b.ext_p1;
exec test_pkg_b.ext_p2;
