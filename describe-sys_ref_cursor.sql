SET SERVEROUTPUT ON 
DECLARE 
  l_cur sys_refcursor;
  l_for_dbms_sql_close NUMBER;
  
  PROCEDURE process_cur 
  (  p_cur iN OUT NOCOPY sys_refcursor
    ,po_for_dbms_sql_close OUT NUMBER
  )
  AS 
    l_cur_num NUMBER;
    l_col_cnt NUMBER;
    l_rows_fetched NUMBER;
    l_dummy_rc NUMBER;
    l_desc_tab dbms_sql.desc_tab;
    TYPE t_clob_assoc_array IS TABLE OF CLOB INDEX BY VARCHAR2(30 CHAR);
    lt_json_inner t_clob_assoc_array; 
    TYPE t_col_flag_array IS TABLE OF BOOLEAN INDEX BY varchar2(30 CHAR);
    lt_col_has_data t_col_flag_array;
    l_col_val_vc2 VARCHAR2(4000 CHAR);
    l_col_val_len   PLS_INTEGER;
    l_attr_name VARCHAR2( 30 CHAR );
    l_json_gesamt CLOB;
  BEGIN 
    l_cur_num := dbms_sql.to_cursor_number( p_cur );
    dbms_sql.describe_columns( l_cur_num, l_col_cnt, l_desc_tab );
    FOR ix IN 1 .. l_col_cnt LOOP
      dbms_output.put_line( ix|| ': ' ||rpad( l_desc_tab(ix).col_name, 60+1, ' ')||rpad(l_desc_tab(ix).col_type, 20, ' ') ||l_desc_tab(ix).col_max_len  );
      IF ix > 1 THEN -- nur ab Spalte 2 im Excel brauchen wir fuer die Spalte ein inneres CLOB
        lt_json_inner( l_desc_tab(ix).col_name ) := empty_clob(); --'"'||replace(l_desc_tab(ix).col_name, '"', '''' )||'": ';
        lt_col_has_data( l_desc_tab(ix).col_name ) := FALSE;
      END IF;
      dbms_sql.define_column ( l_cur_num, position=> ix, column => l_col_val_vc2, column_size=> 4000 ); 
    END LOOP;

FOR ix_col IN 2 .. l_col_cnt LOOP 
    null;--  dbms_output.put_line( ix_col|| ' JSON: ' || lt_json_inner( l_desc_tab(ix_col).col_name ) );
  END LOOP;
    --l_dummy_rc := dbms_sql.execute( l_cur_num );
    while l_rows_fetched IS NULL OR l_rows_fetched > 0
    LOOP
        l_rows_fetched := dbms_sql.fetch_rows( l_cur_num );
          dbms_output.put_line( 'Ln'||$$plsql_line|| ': ' ||'l_rows_fetched:'||l_rows_fetched );

        EXIT  WHEN l_rows_fetched = 0;
        
            for ix_col IN 1 .. l_col_cnt 
            LOOP
--          dbms_output.put_line( 'Ln'||$$plsql_line|| ': ' ||'ix_col:'||ix_col );
              -- einfachheitshalber annehmen, dass alle Spalten VARCHAR2 sind 
              dbms_sql.column_value ( l_cur_num, position=> ix_col, value => l_col_val_vc2 );
              IF ix_col = 1 
              THEN 
                l_attr_name := l_col_val_vc2;
              ELSE 
                IF l_col_val_vc2 IS NOT NULL 
                -- die "Zelle" einen nicht leeren Wert hat, geben wir ein JSON Name-Vaue Paar aus 
                THEN
                  lt_json_inner( l_desc_tab(ix_col).col_name ) :=  lt_json_inner( l_desc_tab(ix_col).col_name ) 
                    || CASE WHEN lt_col_has_data( l_desc_tab(ix_col).col_name ) THEN chr(10)|| ',' ELSE chr(10)||' ' END 
                    ||'"'|| l_attr_name||'": ' || '"'||l_col_val_vc2 ||'"'
                    ;
                  lt_col_has_data( l_desc_tab(ix_col).col_name ) :=  TRUE;
                END IF;             
              END IF;             
            END LOOP;
    end loop; -- over fetched rows 

   dbms_output.put_line( 'GESAMT JSON: ' );
  FOR ix_col IN 2 .. l_col_cnt LOOP 
    l_json_gesamt := l_json_gesamt 
      ||CASE WHEN ix_col > 2 THEN ','||chr(10) END 
    || '"'||l_desc_tab( ix_col).col_name||'":'
      ||'{'
      || CASE WHEN  lt_col_has_data( l_desc_tab(ix_col).col_name  )
      THEN 
        lt_json_inner( l_desc_tab(ix_col).col_name )
      END 
        ||'}'
      ;
     -- dbms_output.put_line( ix_col|| ' JSON: ' || lt_json_inner( l_desc_tab(ix_col).col_name ) );
  END LOOP;
  l_json_gesamt := '{'||l_json_gesamt||'}';
  
  dbms_sql.close_cursor (l_cur_num);
  dbms_output.put_line ( l_json_gesamt );
  END process_cur;
  
BEGIN 
  OPEN l_cur FOR
    SELECT object_name  
      ,object_type
      ,CASE when mod(object_id, 2) = 0 THEN NULL ELSE to_char( object_id ) END AS "obj id"
      , to_char( last_ddl_time , 'yyyy.mm.dd hh24:mi' ) AS last_ddl
      , NULL as "no value"
    FROM user_objects
    WHERE rownum <= 3
  ;
  process_cur( l_cur, l_for_dbms_sql_close );

  OPEN l_cur FOR
    SELECT
        object_type, count(1) "Anzahl", count(distinct status) "distinct Status"
    FROM user_objects
    GROUP BY object_type
    HAVING COUNT(1) > 100
  ;
  process_cur( l_cur, l_for_dbms_sql_close );
END;
/