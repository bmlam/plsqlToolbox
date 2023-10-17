define pi_file_name=&1
define pi_ora_dir_name=&2






set serverout on 

DECLARE 
  lv_dir_name VARCHAR2(100) := '&pi_file_name';
  lv_file_name VARCHAR2(100) := '&pi_ora_dir_name';
  -- lv_fh utl_file.file_type;
  lv_file_exists BOOLEAN; 
  lv_file_length NUMBER; 
  lv_block_size  NUMBER;
begin
   utl_file.FGETATTR( location =>lv_dir_name 
    , filename => lv_file_name
    , FEXISTS => lv_file_exists
    , file_length => lv_file_length
    , block_size =>  lv_block_size
  );
  dbms_output.put_line( 'We may get get FEXISTS = false because the user has only write but NO read privilege!' );
  -- 
  dbms_output.put_line( 'file exists ' || case lv_file_exists when true then 'T' when false then 'F' end );
  dbms_output.put_line( 'file_length ' || lv_file_length);
  dbms_output.put_line( 'block_size ' || lv_block_size);
end;
/
