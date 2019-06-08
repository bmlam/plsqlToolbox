/*
* Use case: frequently you get have to write a stored procedure which takes a list 
* of items such as numeric id or text tokens and in your procedure you want to 
* join this list with another database table or view.
*
* In the piece of code below we simulate that the procedure has got a list of two 
* view name which exist in the data dictionary, cast the list to a anonymous 
* table, join it with ALL_OBJECTS, and print the owner of the given objects.
*
* The principle is to instantiate an object type which is a collection. For 
* convenience I chose SYS.RE$NAME_ARRAY which should exists in every Oracle DB.
* Next we populate the collection. Then we use CAST to transform the collection 
* to a relational entity. If you want to have more than one column in this 
* cast table, you need to define your own object types: RECORD and TABLE
*/

--
-- UPDATE: with ORA_MINING_VARCHAR2_NT, things have become much simpler. Below
-- is an usage example:
-- 
-- SELECT sel.column_value as name, e.salary 
-- FROM TABLE ( ORA_MINING_VARCHAR2_NT( 'King', 'Smith', 'Brown' ) ) sel
-- LEFT JOIN emp e ON e.ename = sel.column_value
-- ;
-- So the code below should be regarded just as a mental exercise from the past
--
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
