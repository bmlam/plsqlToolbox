create or replace package pkg_call_stack_xmp
as
  procedure sub_ext ;
end;
/
show error 

create or replace package body pkg_call_stack_xmp
as
    procedure sub_int_int 
    as 
      lv_stack_text varchar2(2000);
      lv_dump varchar2(2000);
    begin 
      lv_stack_text := DBMS_UTILITY.FORMAT_CALL_STACK();
      dbms_output.put_line( lv_stack_text );
      --
      SELECT dump(lv_stack_text) 
      INTO lv_dump 
      FROM dual
      ;
      dbms_output.put_line( lv_dump );
    end sub_int_int;
    
    procedure sub_int
    as 
    begin 
      sub_int_int;
    end sub_int;
    
  procedure sub_ext as 
  begin 
    sub_int; 
  end sub_ext;
begin
  sub_ext;
end;
/

show error 

set serverout on 
prompt test by: exec pkg_call_stack_xmp.sub_ext