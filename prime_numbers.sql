SET ECHO OFF SCan OFF serverout on timing on linesize 140 pages 100 

rem a procedure to compute prime number and store the result into  table prime_numbers
rem that will be created in code if necessary  
rem one use case is to create database session that will mainly consumes CPU and main storage (PGA)
rem this is only for test and demo purpose and has no practical use. According to en.wikipedia.org
rem  "As of December 2018 the largest known prime number has 24,862,048 decimal digits"
rem this procedure only produces primes up to 38 digits!
rem It uses the Sieve of Eratosthenes algorithm

--BEGIN 
--	--
--	-- run once to create table if it does not yet exist
--	-- 
--	FOR tab_rec IN (
--		SELECT UPPER('prime_numbers') table_name FROM dual 
--		MINUS 
--		SELECT table_name FROM user_tables
--	) LOOP
--		EXECUTE IMMEDIATE 
--q'[
--	 CREATE TABLE prime_numbers
--	( prime NUMBER(38) primary key
--	, run_start timestamp not null 
--	, ts_found  timestamp not null 
--	);
--]';
--	END LOOP; 
--END;
--/

alter session set nls_date_format = 'yyyy.mm.dd hh24:mi:ss';








CREATE OR REPLACE PROCEDURE p_prime_numbers 
( i_start_with NUMBER := 1
 ,i_end_with   NUMBER := NULL
 ,i_max_run_seconds NUMBER := 36
) AS 
-- Excessively huge collection will yield such error:
--
-- SQL> exec p_prime_numbers( 1, 99999999, 600 )
-- BEGIN p_prime_numbers( 1, 99999999, 600 ); END;
-- 
-- *
-- ERROR at line 1:
-- ORA-04036: PGA memory used by the instance exceeds PGA_AGGREGATE_LIMIT
-- ORA-06512: at "LAM.P_PRIME_NUMBERS", line 40
-- ORA-06512: at line 1
	--                                       12345678901234567890123456789012345678
	-- lk_max_end_with                       99999999999999999999999999999999999999;
	l_run_start DATE := SYSDATE;
	l_end_with_used NUMBER(38);
	TYPE h_map_varchar2_to_bool IS TABLE OF BOOLEAN INDEX BY VARCHAR2(100);
	lt_prime_flag h_map_varchar2_to_bool;
	l_number_running NUMBER ;
	l_prime_curr 	 NUMBER; 
	l_prime_maybe  	 NUMBER; 
	l_elapse_secs    NUMBER;
	l_stop  BOOLEAN := FALSE;
	l_safety_countdown NUMBER;
	l_cnt_marked      NUMBER;

	FUNCTION num_to_vc2_index (
		i_num  NUMBER 
	) RETURN VARCHAR2
	AS 
	BEGIN RETURN LPAD( TO_CHAR( i_num ), 38, '0' );
	END num_to_vc2_index;

BEGIN 
	l_safety_countdown := COALESCE( i_end_with/2, 999 );
	l_end_with_used := COALESCE( i_end_with, POWER(10,7));
	dbms_output.put_line( $$plsql_unit||':'||$$plsql_line||' '|| systimestamp ||' l_end_with_used: '||l_end_with_used );

	l_number_running := greatest( 2, i_start_with);
	IF mod( l_number_running, 2 ) = 0 THEN
		l_number_running := l_number_running + 1;
	END IF;
	-- step 1
	lt_prime_flag( num_to_vc2_index(2)  ) := TRUE;
	WHILE l_number_running <= l_end_with_used 
	LOOP
		lt_prime_flag( num_to_vc2_index ( l_number_running) ) := NULL;
		l_number_running := l_number_running + 2;
	END LOOP;

	dbms_output.put_line( $$plsql_unit||':'||$$plsql_line||' '|| systimestamp ||' list elems:'||lt_prime_flag.count );
	dbms_output.put_line( $$plsql_unit||':'||$$plsql_line||' '|| systimestamp ||' firs in list:'||lt_prime_flag.first );
	dbms_output.put_line( $$plsql_unit||':'||$$plsql_line||' '|| systimestamp ||' last in list:'||lt_prime_flag.last );

	l_prime_curr := 2;
	WHILE NOT l_stop 
	LOOP
		-- get next prime from list 
		l_prime_maybe := lt_prime_flag.next( num_to_vc2_index (l_prime_curr) ); 
		dbms_output.put_line( $$plsql_unit||':'||$$plsql_line||' '|| systimestamp ||' prime_maybe: '||l_prime_maybe );
		WHILE l_prime_maybe IS NOT NULL LOOP
			IF lt_prime_flag( num_to_vc2_index (l_prime_maybe) ) IS NULL THEN
				l_prime_curr := l_prime_maybe;
				EXIT;
			END IF;
			l_prime_maybe := lt_prime_flag.next ( num_to_vc2_index (l_prime_maybe) );
		END LOOP; -- over list 

		dbms_output.put_line( $$plsql_unit||':'||$$plsql_line||' '|| systimestamp ||' prime curr: '||l_prime_curr );

		-- save the prime number just found
		MERGE INTO prime_numbers d
		USING ( 
			SELECT l_prime_curr prime FROM DUAL 
		) s
		ON (s.prime = d.prime )
		WHEN NOT MATCHED THEN 
			INSERT ( prime,  run_start, ts_found ) 
			VALUES ( s.prime, l_run_start, systimestamp )
		;
		COMMIT;
		--
		-- mark multiples of current prime 
		--
		l_number_running := l_prime_curr;
		dbms_output.put_line( $$plsql_unit||':'||$$plsql_line||' '|| systimestamp ||' number_running '||l_number_running );
		l_cnt_marked := 0;
		WHILE l_number_running <= l_end_with_used LOOP
			l_number_running := l_number_running + l_prime_curr ;
			DECLARE 
				l_dummy_flag BOOLEAN;
			BEGIN 
				l_dummy_flag := lt_prime_flag( num_to_vc2_index(l_number_running) );
				-- if previous assignment did not raise NO_DATA_FOUND it means the number is in the list 
				--dbms_output.put_line( $$plsql_unit||':'||$$plsql_line||' '|| systimestamp ||' number_running '||l_number_running );
			 	lt_prime_flag( num_to_vc2_index(l_number_running) ):= FALSE;
			 	l_cnt_marked := l_cnt_marked + 1;
			EXCEPTION 
				WHEN NO_DATA_FOUND THEN 
					NULL;
			END mark_num_in_list;

		END LOOP; -- to mark non-primes 
			dbms_output.put_line( $$plsql_unit||':'||$$plsql_line||' '|| systimestamp ||' cnt_marked '||l_cnt_marked );

		l_elapse_secs := ( SYSDATE - l_run_start ) * 1440 * 60;		

		l_stop := l_elapse_secs >= i_max_run_seconds;

		IF NOT l_stop THEN 
			--
			-- if all the next numbers in list are FALSE we can stop 
			-- 
			l_prime_maybe := lt_prime_flag.next ( num_to_vc2_index (l_prime_curr) );
			WHILE l_prime_maybe IS NOT NULL LOOP
				--dbms_output.put_line( $$plsql_unit||':'||$$plsql_line||' '|| systimestamp ||' number_running '||l_number_running );
				EXIT WHEN lt_prime_flag( num_to_vc2_index(l_prime_maybe) ) IS NULL;
				l_prime_maybe := lt_prime_flag.next ( num_to_vc2_index (l_prime_maybe ) );
			END LOOP;

			l_stop := l_prime_maybe IS NULL;
		END IF ;

		l_safety_countdown := l_safety_countdown - 1;
		IF l_safety_countdown = 0 THEN
			raise_application_error(-20001, $$plsql_unit||':'||$$plsql_line||  systimestamp ||' '||' l_safety_countdown reached 0 ' );
			EXIT;
		END IF;
	END LOOP; -- until l_stop 

END;
/

SHOW ERRORS
