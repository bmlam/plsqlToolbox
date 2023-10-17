CREATE OR REPLACE FUNCTION read_blob ( p_id NUMBER )
RETURN BLOB
AS
  l_return BLOB;
BEGIN 
  SELECT binary   
  INTO l_return 
  FROM lam_test_lob@vbsdke r
  WHERE r.id =  p_id
  ;
  RETURN l_return;
END;
/
SHOW ERRORS

