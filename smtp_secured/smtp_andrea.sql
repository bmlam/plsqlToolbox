create or replace procedure test_smtp as 
--DECLARE

  c utl_smtp.connection;

  l_mailhost    VARCHAR2 (64) := 'smtp.office365.com';

  l_from        VARCHAR2 (64) := 'lion-xxx@yyy.com';

  l_to          VARCHAR2 (64) := 'blam2.ccccc.de';

  l_subject     VARCHAR2 (64) := 'Hello World';

  crlf varchar2(2) := UTL_TCP.CRLF;

BEGIN

  c := utl_smtp.open_connection(

            host => l_mailhost,

            port => 587,

            secure_host => 'outlook.com',

            wallet_path => 'file:/u00/app/oracle/product/12.2.0/icelionmtet1/data/wallet',

            wallet_password => 'gssdfgfgg.386',

            secure_connection_before_smtp => FALSE);

            

  UTL_SMTP.ehlo(c, 'fgf.gsdfgfs.com');

  UTL_SMTP.STARTTLS(c, secure_host => 'outlook.com');

  UTL_SMTP.ehlo(c, 'fsgfgf.fgsfdfg.com');

 

  utl_smtp.command( c, 'AUTH LOGIN');

  utl_smtp.command( c, 'bGlvbi1leGFkYXRhQGljZXNlcnZpY2VzLmNvbQ==');

  utl_smtp.command( c, 'QTd3eXE0cEF4ekV4');  

 

  UTL_SMTP.mail (c, l_from);

  UTL_SMTP.rcpt (c, l_to);

  UTL_SMTP.open_data (c);

  UTL_SMTP.write_data (c, 'Date: ' || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || crlf);

  UTL_SMTP.write_data (c, 'From: ' || l_from || crlf);

  UTL_SMTP.write_data (c, 'Subject: ' || l_subject || crlf);

  UTL_SMTP.write_data (c, 'To: ' || l_to || crlf);

  UTL_SMTP.write_data (c, '' || crlf);

 

  FOR i IN 1 .. 10

  LOOP

    UTL_SMTP.write_data (c, 'Apparently it is working! Line ' || TO_CHAR (i) || crlf);

  END LOOP;

 

  UTL_SMTP.close_data (c);

  UTL_SMTP.quit (c); 

END;

/

show errors