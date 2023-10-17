define pi_filename=&1
define pi_oradir=&2






set serverout on echo on 

DECLARE 
   lv_fh utl_file.file_type;
begin
    lv_fh :=
      UTL_FILE.fopen('&pi_oradir'
                   , '&pi_filename'
                   , 'a'
                   , 32767);
    UTL_FILE.put_line(lv_fh, 'Hello world');
    UTL_FILE.fclose(lv_fh);
end;
/
