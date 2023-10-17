def pi_store_proc_name=&1
begin
  dbms_scheduler.create_job (
   job_name           =>  'LAM_TMP_JOB'||to_char(sysdate, 'yyyymmdd_hh24miss' ), -- choose meaning full name
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  upper('&pi_store_proc_name'),
   start_date         =>  sysdate,
   enabled            =>  true);
end;
/

-- create or replace procedure LAM_TEST_SCHEDULER as begin     user_lock.sleep (tens_of_millisecs => 1000000 ); end;