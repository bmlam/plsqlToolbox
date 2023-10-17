CREATE OR REPLACE PROCEDURE vbsowner.write_blob ( p_id NUMBER, p_blob BLOB )
AS
  l_blob BLOB; 
BEGIN 
  DELETE vbsowner.lam_temp_blob WHERE id = p_id;
  INSERT into vbsowner.lam_temp_blob ( id, binary ) VALUES ( p_id, p_blob)  
  RETURNING binary INTO l_blob
  ;
  --DELETE cmsowner.lam_temp_blob@vbsdke WHERE id = p_id;
  --INSERT INTO lam_temp_blob@vbsdke ( id, binary ) VALUES ( p_id, l_blob)  ;
  -- sync_blob@vbsdke( p_id );
  UPDATE lam_test_lob@vbsdke SET binary = l_blob
  WHERE id = p_id;
END;
/
SHOW ERRORS
