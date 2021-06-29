-- a handy script to create synonyms for a schema which is meant to fake an application schema
with obj_ as ( 
select owner, table_name object_name
 , count(distinct owner) over(partition by table_name ) obj_occ
 , row_number() over(partition by table_name order by null)  seq
from all_tab_privs_recd
where 1=1
  and owner in ( 'USER1', 'USER2')
)
select null " "
--o.owner, o.object_name , o.obj_occ
-- , s.synonym_name
-- , s.owner syn_owner
 , uo.object_name 
 , 'CREATE OR REPLACE SYNONYM ' ||o.object_name||' FOR '||o.owner||'.'||o.object_name||';' ddl 
from obj_ o
left join all_synonyms s on o.object_name = s.table_name and o.owner = s.table_owner and s.owner in ( user, 'PUBLIC' )
left join user_objects uo on uo.object_name = o.object_name and uo.object_type in ( 'TABLE', 'VIEW', 'FUNCTION', 'PROCEDURE', 'TYPE', 'PACKAGE', 'SEQUENCE' )
where 1=1 
  and o.seq = 1
  and s.synonym_name is null 
  and uo.object_name is null 
  and o.object_name not like 'BIN$%'
  and o.object_name in ( 'OBJ1', 'OBJ2', 'xx' )
order by o.object_name, o.owner 
 ;
 