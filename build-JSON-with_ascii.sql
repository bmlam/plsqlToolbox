VAR l_json VARCHAR2(1000)

SET SERVEROUT ON 

DECLARE 
BEGIN 
  FOR lr iN (
    WITH src_text AS (
      SELECT 'URL Präfix zum DIGIHB Server' value 
      FROM  dual 
      UNION ALL 
      SELECT 'Man weiß nicht alles ÜBER alles' value 
      FROM  dual 
    ), with_ua AS 
    (
      SELECT value 
      FROM src_text
      UNION ALL 
      SELECT convert( value, 'utf8', 'us7ascii' )
      FROM src_text
    )
    SELECT value
    FROM with_ua
    ORDER BY mod( rownum, 2 ) -- force order of: first one original value,  next the converted value thereof 
  ) LOOP
    dbms_output.put_line( 'value: '||lr.value );
    BEGIN 
      SELECT  json_object(  'name' IS 'name'
                          , 'value' IS lr.value 
                         )
        INTO  :l_json
        FROM  dual;
    EXCEPTION 
      WHEN OTHERS THEN 
        dbms_output.put_line( sqlerrm );
        dbms_output.put_line( 'value: '||lr.value );
    END; 
  END LOOP;
END;
/

print :l_json