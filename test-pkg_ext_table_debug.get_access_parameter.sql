set serverout on scan on

set long 40000 longchunksize 40000 lines 140 pages 100

select  lam_pkg_ext_table_debug.get_access_parameter ( 'REJECT LIMIT', 'MY_TEST_TABLE2') para_value
from dual
;
