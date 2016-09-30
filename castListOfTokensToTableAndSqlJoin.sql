/*
* Use case: frequently you get have to write a stored procedure which takes a list 
* of items such as numeric id or text tokens and in your procedure you want to 
* join this list with another database table or view.
*
* In the piece of code below we simulate that the procedure has got a list of two 
* view name which exist in the data dictionary, cast the list to a anonymous 
* table, join it with ALL_OBJECTS, and print the owner of the given objects.
*/

set serveroutput on 

declare 
  a sys.RE$NAME_ARRAY := sys.RE$NAME_ARRAY();
begin
  a.extend(2);
  a(1) := 'ALL_TABLES';
  a(2) := 'ALL_VIEWS';
  dbms_output.put_line( 'count: '||a.count );
  for rec in ( 
    with cast_table as ( 
      select '?' my_name -- give a name to our one and only attribute in the table element of a
      -- I used to know the predefined attribute name but at this time I can't recall
      from dual where 1=0
      union all
      select *
      from table ( a )
    ) 
    select o.owner, c.my_name
    from cast_table c
    join all_objects o
    on ( o.object_name = c.my_name )
  ) loop
    dbms_output.put_line( rec.my_name ||' is owned by '|| rec.owner );
  end loop;
end;
/