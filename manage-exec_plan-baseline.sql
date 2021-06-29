Get the signature from SQLID


select force_matching_signature from v$sql where sql_id='6xkh01t2cynma';
Check if Baseline exists


select * from dba_sql_plan_baselines where signature=16375286710734935547
select plan_name,enabled,accepted,fixed,reproduced from dba_sql_plan_baselines where signature=18280607655017243025
Create Baseline with a first Plan from cache


set serveroutput on;
DECLARE
l_plans_loaded PLS_INTEGER;
BEGIN
l_plans_loaded := DBMS_SPM.load_plans_from_cursor_cache( sql_id => '528ndy857r5rh', plan_hash_value=>'62022230');
dbms_output.put_line('Number of plans loaded: '||l_plans_loaded);
END;
/



Add Plan from AWR

Create SQLSET


begin
DBMS_SQLTUNE.CREATE_SQLSET('528ndy857r5rh');
end;/
Check SQLSET


select * from DBA_SQLSET;
Load Execution Plan into SQLSET


declare
baseline_ref_cursor DBMS_SQLTUNE.SQLSET_CURSOR;
begin
open baseline_ref_cursor for
select VALUE(p) from table(DBMS_SQLTUNE.SELECT_WORKLOAD_REPOSITORY(64392, 64393,
'sql_id='||CHR(39)||'528ndy857r5rh'||CHR(39)||' and plan_hash_value=2378416600',NULL,NULL,NULL,NULL,NULL,NULL,'ALL')) p;
DBMS_SQLTUNE.LOAD_SQLSET('528ndy857r5rh', baseline_ref_cursor);
end;/

set serveroutput on
declare
my_integer pls_integer;
begin
my_integer := dbms_spm.load_plans_from_sqlset (
sqlset_name => 'test2',
sqlset_owner => 'BROZA',
fixed => 'NO',
enabled => 'YES'
);
DBMS_OUTPUT.PUT_line(my_integer);
end;
/
Change Attributes of a Plan


declare
myplan pls_integer;
begin
myplan:=DBMS_SPM.ALTER_SQL_PLAN_BASELINE (sql_handle => 'SQL_fdb1c3ceb396e191',plan_name => 'SQL_PLAN_gvcf3tuttdscj03b26256',attribute_name => 'FIXED', attribute_value => 'YES');
end;/
Change Attributes of a Plan - 
ACCEPT A PLAN
in 12c

SET SERVEROUTPUT ON
SET LONG 10000
DECLARE
x clob;
BEGIN
x := dbms_spm.evolve_sql_plan_baseline
('SQL_e657616e69731a93',
'SQL_PLAN_fcpv1dtnr66nm8d0ccae8',
VERIFY=>'NO' ,
COMMIT=>'YES');
DBMS_OUTPUT.PUT_LINE(x);
END;
Drop plan

declare
drop_result pls_integer;
begindrop_result := DBMS_SPM.DROP_SQL_PLAN_BASELINE(sql_handle => 'SQL_164b2be280f1ffba',
plan_name => 'SQL_PLAN_1cktbwa0g3zxu06dab5d5');dbms_output.put_line(drop_result);
end;

