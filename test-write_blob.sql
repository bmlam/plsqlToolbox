SET ECHO ON 

MERGE INTO lam_test_lob@vbsdke  z
USING ( SELECT 1 AS id FROM dual) q
ON( q.id = z.id ) 
WHEN NOT MATCHED THEN INSERT ( id ) VALUES ( 1 )
;
COMMIT;

SET SERVEROUTPUT ON TIME ON 
DECLARE
  l_blob BLOB ; 
  l_pattern_100_char VARCHAR2(100 CHAR) := to_char( sysdate, 'yyyymmddhh24miss') ||rpad( '0', 86, '0');
  l_buffer_10000_char VARCHAR2(10000 CHAR);
  l_warning NUMBER;
  l_lang_context NUMBER := 0;
  l_offset_src NUMBER := 1;
  l_offset_dst NUMBER := 1;
  l_clob CLOB;
BEGIN 
  FOR i in 1 .. 100 LOOP
    l_buffer_10000_char := l_buffer_10000_char || l_pattern_100_char;
  END LOOP;
  dbms_output.put_line( 'buffer Size: '||length( l_buffer_10000_char) );
  --l_buffer_raw := hextoraw ( l_buffer_10000_char ) ;
  --dbms_output.put_line( 'buffer Size: '||length( l_buffer_raw) );
  SELECT empty_blob() INTO l_blob
  FROM dual
  ;
  FOR i in 1 .. 100 LOOP
    l_clob := l_clob||l_buffer_10000_char;
  END LOOP;
  dbms_output.put_line( 'clob Size: '||dbms_lob.getlength( l_clob ) );
  dbms_lob.createtemporary(l_blob, FALSE);
  dbms_lob.CONVERTTOBLOB(
   dest_lob     => l_blob,
   src_clob     => l_clob,
   amount       => dbms_lob.getlength( l_clob ),
   dest_offset  => l_offset_dst,
   src_offset   => l_offset_src,
   blob_csid    => 0,
   lang_context => l_lang_context,
   warning      => l_warning);
  dbms_output.put_line( 'blob Size: '||dbms_lob.getlength( l_blob ) );
  
  write_blob( 1, l_blob);
  
  COMMIT;
END;
/

COLUMN lob_start format A50
SELECT dbms_lob.getlength( read_blob(1) ) lob_size 
   , utl_raw.cast_to_varchar2 (  dbms_lob.substr ( read_blob(1), amount=> 40, offset=> 1 ) ) lob_start
FROM dual
;
SET ECHO OFF TIME OFF 