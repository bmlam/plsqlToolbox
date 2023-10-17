DECLARE 
  src_blob BLOB;
-- CREATE TABLE test_blob ( quality NUMBER not null, data_compressed BLOB, org_len NUMBER );
BEGIN 
  SELECT dokument INTO src_blob
  FROM cmt_dokumente_lob
  WHERE id = 13355910
  ;
  FOR q IN 1 .. 9
  LOOP
    INSERT INTO test_blob values ( q, utl_compress.lz_compress (src=> src_blob, quality => q) , dbms_lob.getlength(src_blob) ) ;
    COMMIT;
  END LOOP;
END;
/

SELECT quality, org_len, dbms_lob.getlength( data_compressed ) NEW_len FROM test_blob ORDER BY org_len, quality;