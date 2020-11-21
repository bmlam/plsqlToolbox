set serveroutput on 

declare 
  gk_crlf             CONSTANT CHAR(2) := chr(13)||chr(10);
  lv_error_text LONG;
begin
  sk_secure_mail.ep_send_mail( pi_recipients=> 'bon-minh.lam@fgfgssfd.com', pi_subject=> 'ping'
  , pi_mail_text => 'text composed '||gk_crlf||'at'||gk_crlf||to_char( sysdate, 'yyyy.mm.dd hh24:mi:ss'), po_error_text => lv_error_text );
  dbms_output.put_line( 'len(error)='||length( lv_error_text ) );
  dbms_output.put_line( 'error: '|| lv_error_text  );
end;
/  

col msg format a80
set lines 200 pages 100

select * from my_log order by id desc fetch first 15 rows only;