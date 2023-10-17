CREATE OR REPLACE FUNCTION string_to_table (
    pic_string                   VARCHAR2
  , pic_delimiter                VARCHAR2 DEFAULT ','
)
RETURN dbms_utility.uncl_array 
    AS
    ln_sep_pos    INTEGER;
    ln_str_len   INTEGER        := LENGTH (pic_string);
    ln_scan_pos   INTEGER        := 1;
    lc_element    VARCHAR2(1000  CHAR);
    lt_return  dbms_utility.uncl_array;
    kn_col_sep_len CONSTANT INTEGER := LENGTH( pic_delimiter );
  BEGIN
    --dbms_output.put_line( 'Ln'||$$plsql_line||' ln_str_len:'|| ln_str_len ); 
    WHILE ln_scan_pos <= ln_str_len LOOP
      --dbms_output.put_line( 'Ln'||$$plsql_line||' ln_scan_pos:'|| ln_scan_pos );
      ln_sep_pos := INSTR (pic_string, pic_delimiter, ln_scan_pos);
      lc_element :=
        CASE
          WHEN ln_sep_pos > 0 THEN substr(pic_string, ln_scan_pos, ln_sep_pos - ln_scan_pos )
          ELSE substr (pic_string, ln_scan_pos)
        END;
      --dbms_output.put_line( 'Ln'||$$plsql_line||' sep_pos:'|| ln_sep_pos||' lc_element:'|| lc_element); 
      lt_return (lt_return.COUNT + 1) := lc_element;
      ln_scan_pos := 
        CASE 
        WHEN ln_sep_pos > 0 THEN ln_scan_pos + kn_col_sep_len + coalesce( length(lc_element), 0 ) -- length( '' ) -> NULL 
        ELSE ln_str_len + 1
        END;
    END LOOP;
    -- Sonderbehandlung: wenn demiliter genau am Ende des Eingabestring ist, ein leeres Element hinzufügen
    IF ln_sep_pos + kn_col_sep_len - 1 = ln_str_len THEN
      lt_return (lt_return.COUNT + 1) := NULL;
    END IF;
    -- Sonderbehandlung: wenn demiliter im Eingabestring kein einziges mal vorkommt and der Eingabestring nicht leer ist
    -- den String als einziges Element zurückliefern.
    IF lt_return.COUNT = 0 
      AND pic_string IS NOT NULL 
    THEN 
      lt_return (lt_return.COUNT + 1) := pic_string;
    END IF;

    RETURN lt_return;
END;
/
show error 

set serverout on 
DECLARE 
  tab dbms_utility.uncl_array;
BEGIN 
  FOR lr IN (
    SELECT '?????????????' txt , ',' sep FROM dual 
    UNION ALL SELECT ''   , ',' FROM dual 
    UNION ALL SELECT ' ' , ','   FROM dual 
    UNION ALL SELECT 'abc', '#'    FROM dual 
    UNION ALL SELECT ',abc,,', ','    FROM dual 
    UNION ALL SELECT ';#;abc;def;' , ';'   FROM dual 
    UNION ALL SELECT ';#;abc;#;def;#;' , ';#;'   FROM dual 
    --UNION ALL SELECT 'abc,def,ghi'    FROM dual 
  ) LOOP
    dbms_output.put_line( '***********************************************');
    dbms_output.put_line( 'sept:' ||lr.sep ||' txt:' ||lr.Txt );
    tab := string_to_table( lr.txt,  lr.sep  );
    FOR ix IN 1 .. tab.count
    LOOP
      dbms_output.put_line( 'elem '||ix||':"' ||tab(ix)||'"');
    END LOOP;
  END LOOP;
END;
/