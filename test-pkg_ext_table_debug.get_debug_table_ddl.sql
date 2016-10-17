set serverout on 

set long 40000 longchunksize 40000 lines 140 pages 100

select  pkg_ext_table_debug.get_debug_table_ddl ( 'MY_TEST_TABLE', user, p_table_new => 'my_test_table' ) ddl
from dual
;
