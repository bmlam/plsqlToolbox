-- If you have to construct a large CLOB by appending text to the end of the CLOB in many, many iterations
-- the handy double pipe operator will slow down the processing.
-- using DBMS_LOB.GET_LENGTH and WRITE methods is much faster  
-- This script demonstrates the difference

create or replace function demo_fast_clob_build (
	p_test_rows integer default 10000
	,p_slow_mode integer default 1
)
return clob
IS
	l_return clob;
	c_nl varchar2(10) := chr(10);
	l_offset integer;
	l_chunk varchar2(1000) -- CHARACTER SET lob_loc%CHARSET
	;
BEGIN
	select '-- Demo fast CLOB build: list '||to_char( count(1) )||' object from all_objects '||c_nl 
	into l_return -- use SELECT to initialize CLOB
	from all_objects
	where rownum <= p_test_rows
	;
	/* header */ 
	if p_slow_mode > 0 then 
		l_offset := dbms_lob.getlength( l_return );
	end if;
	/* loop to compile CLOB body */ 
	for rec in ( 
		select object_id||';'||owner||';'||object_name||';'||object_type as chunk
		from all_objects
		where rownum <= p_test_rows
	) loop
		l_chunk := rec.chunk||c_nl;
		if p_slow_mode = 0 then
			l_return := l_return||l_chunk;
		else 
			dbms_lob.write( l_return, lengthc(l_chunk), l_offset + 1, l_chunk);
			l_offset := l_offset + lengthc(l_chunk);
		end if;
	end loop;
	/* footer */ 
	l_chunk := c_nl||'--- end of list --- ';
	if p_slow_mode = 0 then
		l_return := l_return||l_chunk;
	else 
		dbms_lob.write( l_return, lengthc(l_chunk), l_offset + 1, l_chunk);
		l_offset := l_offset + lengthc(l_chunk);
	end if;
	-- 
	return l_return;
end;
/

show errors

spool c:\temp\xxx.txt 

set timing on long 1000000 lines 100 pages 0
set termout off trimspool on 

prompt Fast mode 
select demo_fast_clob_build( p_test_rows=> 10000, p_slow_mode => 0) test from dual;

prompt Slow mode 
select demo_fast_clob_build( p_test_rows=> 10000, p_slow_mode => 1) test from dual;

spool off