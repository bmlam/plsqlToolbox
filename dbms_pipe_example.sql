set serverout on 

begin 
   IF dbms_pipe.create_pipe (
      pipename => '2018test'
      --,maxpipesize IN INTEGER DEFAULT 8192,
      --private IN BOOLEAN DEFAULT TRUE
      ) = 0 THEN
         dbms_output.put_line( 'Line '||$$plsql_line||': '|| 'pipe created');
   ELSE 
         RAISE_APPLICATION_ERROR( -20001, 'bad luck with pipe create');
   END IF;
END;
/

create or replace procedure pipe_sender AS
      l_rc INTEGER;
      l_protocol_version INTEGER := 1;
begin
      FOR m_ix IN 1 .. 3 LOOP
         dbms_output.put_line( 'Line '||$$plsql_line||': '|| m_ix );
         -- in real life the normal use case is that there are many senders and one receiver
         -- when updating the format of the payload messae sent over the pipe, some senders may still be
         -- using the older formats.
         -- It is a good idea to exchange the protocol version as the first step.The receiver  
         -- can cater for old formats based on the version so that things are not broken.
         dbms_pipe.pack_message( l_protocol_version ); 
         dbms_pipe.pack_message( 1233 + m_ix );
         dbms_pipe.pack_message( rpad( 'how do you do?', 4000,'*' ) ); -- make message real big to force buffer full condition
         FOR try IN 1 .. 3 LOOP
            dbms_output.put_line( 'Line '||$$plsql_line||': '|| try );
            l_rc := dbms_pipe.send_message( '2018test' , timeout => 3 );
            -- not that buffer full may also result in "ORA-06558: buffer in dbms_pipe package is full.  No more items allowed" 
            -- it seems that Oracle set a package variable to remember this status. Even if the pipe has been unloaded later on
            -- for the session, the pipe is unusable. This is proved by running DBMS_SESSION.RESET_PACKAGE but this is usually
            -- not a viable option. 
            CASE l_rc 
            WHEN 0 THEN 
               EXIT;
            WHEN 1 THEN NULL; -- retry. One reason for Timeout on send is the buffer is full which happens when the receiver lags behind.  
            -- WHEN 2: this RC is not listed in the docs. 
            WHEN 3 THEN RAISE_APPLICATION_ERROR( -20001, 'dbms_pipe interrupted'); -- retry
            ELSE RAISE_APPLICATION_ERROR( -20002, 'unexpected RC '||l_rc );
            END CASE;
         END LOOP; -- over tries
         DBMS_LOCK.SLEEP(3);
      END LOOP;
END;
/

show errors

create or replace procedure pipe_reader AS
   l_rc INTEGER;
   l_protocol_version INTEGER;
   l_num NUMBER;
   l_text VARCHAR2( 30000 BYTE );
   lc_timeout CONSTANT INTEGER := 2;
begin
   WHILE TRUE LOOP
      l_rc := dbms_pipe.receive_message( '2018test', lc_timeout );
      CASE l_rc 
      WHEN 0 THEN NULL; -- wait for next message
      WHEN 1 THEN 
         dbms_output.put_line( 'Line '||$$plsql_line||': '|| 'receive timed out');
         EXIT; -- if production the receiver must not quit! 
      WHEN 2 THEN 
         RAISE_APPLICATION_ERROR( -20001, 'Record too large for buffer. Should not happen according to the docs');
      WHEN 3 THEN 
         RAISE_APPLICATION_ERROR( -20002, 'dbms_pipe interrupted'); 
      ELSE 
         RAISE_APPLICATION_ERROR( -20003, 'unexpected RC '||l_rc );
      END CASE;
      dbms_pipe.unpack_message( l_protocol_version );
      dbms_output.put_line( 'Line '||$$plsql_line||': '|| l_protocol_version );
      dbms_pipe.unpack_message( l_num );
      dbms_output.put_line( 'Line '||$$plsql_line||': '|| l_num );
      dbms_pipe.unpack_message( l_text );
      dbms_output.put_line( 'Line '||$$plsql_line||': '|| l_text );
   END LOOP;      
END;
/
show errors

      