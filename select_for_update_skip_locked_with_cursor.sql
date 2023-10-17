CREATE TABLE lam_test1 AS SELECT object_id id, substr( object_name, 1, 6) shortname FROM user_objects where rownum <= 5;

ALTER TABLE lam_test1 ADD ( stat VARCHAR2(5) );

SELECT * FROM lam_test1 ORDER BY id;

SELECT systimestamp now FROM DUal
;

SET SERVEROUTPUT ON TIMING on 

DECLARE 
  CURSOR c1 IS
    SELECT id, shortname FROM lam_test1
    WHERE stat IS NULL 
    ORDER BY id 
    FOR UPDATE SKIP LOCKED
  ;
  l_id number; 
  l_name VARCHAR2(10);
BEGIN 
  LOOP 
    l_id := null; 
    OPEN c1;
    FETCH c1 iNTO l_id, l_name;
    CLOSE c1; 
    IF l_id IS NULL THEN 
      EXIT;
    END IF; 
    dbms_output.put_line( systimestamp|| ' got id: '||l_id||' name:'||l_name);
    update lam_test1 SET stat = 'Done' WHERE id = l_id;
    dbms_lock.sleep(1);
   COMMIT; -- release row lock 
   
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN 
    dbms_output.put_line( systimestamp||sqlerrm );
END;
/


 