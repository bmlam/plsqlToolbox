CREATE OR REPLACE FUNCTION show_as_ua_view (
   p_query        IN VARCHAR2
  ,p_table_name   IN VARCHAR2
  ,p_table_owner  IN VARCHAR2 DEFAULT NULL
  ,p_date_fmt IN VARCHAR2 DEFAULT 'dd-mon-yyyy hh24:mi:ss'
  
) RETURN CLOB
-- this utility is designed to transform data from a query result set into 
-- a beautified UNION ALL view 
-- Test:
--  select show_as_ua_view( 'select * from user_objects where rownum < 2' ) from dual;
  AUTHID current_user
IS
  l_return  CLOB;
  l_thecursor INTEGER DEFAULT dbms_sql.open_cursor;
  l_col_value VARCHAR2(4000);
  l_status  INTEGER;
  lt_col_info dbms_sql.desc_tab2;
  l_col_cnt  NUMBER;
  l_cs  VARCHAR2(255);
  l_date_fmt  VARCHAR2(255);
  l_cols_description VARCHAR2(4000);
  TYPE t_col_max_len IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  lt_col_max_len t_col_max_len;
  l_row_ix NUMBER := 0;
  l_col_len NUMBER;
  l_col_def_span NUMBER;
  
  TYPE t_varchar2_array IS TABLE OF VARCHAR2(4000) ;
  lt_tab_column_name   t_varchar2_array;
  TYPE t_columns_of_row IS TABLE OF VARCHAR2(4000) INDEX BY PLS_INTEGER;
  TYPE t_matrix IS TABLE OF t_columns_of_row INDEX BY PLS_INTEGER;
  l_columns_of_row  t_columns_of_row;
  l_matrix  t_matrix;

-- small inline procedure to restore the sessions state
-- we may have modified the cursor sharing and nls date format
-- session variables,this just restores them

  PROCEDURE restore
  IS
  BEGIN
  IF  (  upper(l_cs) NOT IN (    'FORCE','SIMILAR'  )  )
  THEN
    EXECUTE IMMEDIATE 'alter session set cursor_sharing=exact';
  END IF;

  IF  (  p_date_fmt IS NOT NULL  )  THEN
    EXECUTE IMMEDIATE 'alter session set nls_date_format=''' || l_date_fmt || '''';
  END IF;

  dbms_sql.close_cursor(l_thecursor);
  END restore;

BEGIN
-- col_ix like to see the dates print out with times,by default,the
-- format mask col_ix use includes that. In order to be “friendly�?
-- we save the date current sessions date format and then use
-- the one with the date and time. Passing in NULL will cause
-- this routine just to use the current date format
  IF  p_date_fmt IS NOT NULL    THEN
    SELECT  sys_context(  'userenv',  'nls_date_format'  )
    INTO  l_date_fmt
    FROM
    dual;

    EXECUTE IMMEDIATE 'alter session set nls_date_format=''' || p_date_fmt || '''';
  END IF;

-- to be bind variable friendly on this ad-hoc queries,we
-- look to see if cursor sharing is already set to FORCE or
-- similar,if not,set it so when we parse — literals
-- are replaced with binds
  $IF $$got_get_param_priv = 1 $THEN
    IF dbms_utility.get_parameter_value(  'cursor_sharing',  l_status,  l_cs  ) = 1 
    THEN
      IF  upper(l_cs) NOT IN (    'FORCE','SIMILAR'  )      THEN
        EXECUTE IMMEDIATE 'alter session set cursor_sharing=force';
      END IF;
    END IF;
  $END

  SELECT column_name
  BULK COLLECT INTO lt_tab_column_name
  FROM all_tab_columns
  WHERE owner = COALESCE( upper( p_table_owner ), user ) 
    AND table_name = upper( p_table_name )
  ORDER BY column_id
  ;
-- parse and describe the query sent to us. we need
-- to know the number of columns and their names.

  dbms_sql.parse(  l_thecursor,  p_query,  dbms_sql.native  );
  dbms_sql.describe_columns2(  l_thecursor,  l_col_cnt,  lt_col_info  );

  IF l_col_cnt <> lt_tab_column_name.count THEN
    RAISE_APPLICATION_ERROR( -20001, 'Error: l_col_cnt='||l_col_cnt||' NOT EQUAL lt_tab_column_name.count='||lt_tab_column_name.count );
  END IF;
-- define all columns to be cast to varchar2's,we
-- are just printing them out
  FOR col_ix IN 1..l_col_cnt LOOP
    -- col_type data_type
    --        1 Varchar
    --        2 Number
    --       12 Date
    IF  lt_col_info(col_ix).col_type NOT IN (    113  )
    THEN
      dbms_sql.define_column(  l_thecursor,  col_ix,  l_col_value,  4000  );
      lt_col_max_len( col_ix ) := 0;
      l_cols_description := CASE WHEN col_ix > 1 THEN l_cols_description||', ' END 
        || lt_col_info( col_ix ).col_name ||': '|| lt_col_info( col_ix ).col_type
      ;
    END IF;
  END LOOP;

-- execute the query,so we can fetch

  l_status := dbms_sql.execute(l_thecursor);

-- loop and print out each column on a separate line
-- bear in mind that dbms_output only prints 255 characters/line
-- so we'll only see the first 200 characters by my design…
  WHILE ( dbms_sql.fetch_rows(l_thecursor) > 0 ) LOOP
    FOR col_ix IN 1..l_col_cnt LOOP
    IF    lt_col_info(col_ix).col_type NOT IN (    113    )
    THEN
        dbms_sql.column_value(          l_thecursor,          col_ix,          l_col_value        );
        --dbms_output.put_line(rpad(    lt_col_info(col_ix).col_name,    30
        --)   || ': '   || substr(    l_col_value,    1,    200  ) );
        l_columns_of_row( col_ix ) := l_col_value;
        l_col_len := length( l_col_value );
        -- determine max len of column
        IF l_col_len > lt_col_max_len( col_ix ) THEN 
          lt_col_max_len( col_ix ) := l_col_len; 
        END IF;
    END IF;
    
    END LOOP;
    l_row_ix := l_row_ix + 1; 
    l_matrix( l_row_ix ) := l_columns_of_row;
    
  END LOOP; -- over rows

  FOR col_ix IN 1 .. lt_col_info.count LOOP
    l_col_def_span := LEAST ( 
      LENGTH ( lt_tab_column_name( col_ix ) ) + 2 /*for comma and space*/ 
        + CASE lt_col_info( col_ix ).col_type 
        WHEN  1 /* string */ THEN 3
        WHEN  2 /* number */ THEN 1
        WHEN 12 /* date */   THEN 7
        ELSE  3
        END 
      , lt_col_max_len( col_ix ) + 2 /*for comma and space*/ 
        + CASE lt_col_info( col_ix ).col_type 
        WHEN  1 /* string */ THEN 2
        ELSE  1
        END 
       )
      ;
    l_cols_description :=       CASE WHEN col_ix > 1 THEN l_cols_description||',' END
      ||lpad(        
          CASE lt_col_info( col_ix ).col_type 
          WHEN  1 /* string */ THEN '1'
          WHEN  2 /* number */ THEN '''?'''
          WHEN 12 /* date */   THEN 'sysdate'
          ELSE  '???'
          END 
          ||' '||lt_tab_column_name( col_ix )
          , l_col_def_span, ' ' )
      ;
  END LOOP;
  l_return := l_cols_description; 
  
  -- l_return := 'SELECT ' 
  FOR row_ix IN 1 .. l_matrix.count LOOP
      null;
  END LOOP;
-- now,restore the session state,no matter what

  restore;
  
  RETURN l_return;
EXCEPTION
  WHEN OTHERS THEN
    restore;
    RAISE;
END;
/

SHOW ERRORS