-- demonstrate the behaviour of a indexed by number table - basically an associate array -
-- becoming sparse and how to iterate thru it.
-- In my opinion, it is not wise to make such an array sparse because dealing with it 
-- is slightly more tricky. Why delete elements from it in the first place?

set serveroutput on

declare
	cursor cur is 
	select object_id, object_type, object_name
	from all_objects
	where rownum <= 5
	;
	-- type t_tab is table of cur%rowtype index by binary_integer;
	type t_tab is table of cur%rowtype; -- this works the same way as the line above! 
	vtab t_tab;
	v_ix number;
begin
	open cur;
	fetch cur bulk collect into vtab;
	dbms_output.put_line( $$plsql_line||' count:'|| vtab.count );
	for i in 1 .. vtab.count loop
		dbms_output.put_line( $$plsql_line||' :'|| vtab(i).object_name );
	end loop;
	dbms_output.put_line( $$plsql_line||' count:'|| vtab.count );
	v_ix := vtab.first;
	while v_ix is not null loop
		dbms_output.put_line( $$plsql_line||' v_ix:'|| v_ix||' is '|| vtab(v_ix).object_name );
		v_ix := vtab.next( v_ix );
	end loop;
end;
/

prompt testing with VARRAY
prompt VARRAY can not become sparse. Elements must always be removed from the end.
prompt the DELETE method removes all elements from the VARRAY

declare
	cursor cur is 
	select object_id, object_type, object_name
	from all_objects
	where rownum <= 5
	;
	type t_tab is varray(5) of cur%rowtype; 
	vtab t_tab;
	v_ix number;
begin
	open cur;
	fetch cur bulk collect into vtab;
	dbms_output.put_line( $$plsql_line||' count:'|| vtab.count );
	for i in 1 .. vtab.count loop
		dbms_output.put_line( $$plsql_line||' :'|| vtab(i).object_name );
	end loop;
	--compile error: vtab.delete(3); 
	-- the next line removes 3 elements from the end
	vtab.trim(3); 
	dbms_output.put_line( $$plsql_line||' count:'|| vtab.count );
	v_ix := vtab.first;
	while v_ix is not null loop
		dbms_output.put_line( $$plsql_line||' v_ix:'|| v_ix||' is '|| vtab(v_ix).object_name );
		v_ix := vtab.next( v_ix );
	end loop;
	vtab.delete; -- removes all elements
	dbms_output.put_line( $$plsql_line||' count:'|| vtab.count );
end;
/
	
