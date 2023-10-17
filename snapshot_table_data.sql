define pi_owner_origin=&1
define pi_table_origin=&2
rem for pi_part_hier provide ? for non-partitioned table, otherwise part or subpart 
define pi_part_hier=&3  
define pi_part_or_subpart_name=&4
rem for pi_modulo provide ? or an integer. A modulo filter will be applied if an integer is given 
define pi_modulo=&5
define pi_comments=&6


-- call example on gd1:
-- sta C:\projects\sandbox\toolbox\snapshot_table_data.sql LICENSING t_ipty_shares part t_ipty_shares_p101248 0 ? ?

--CREATE TABLE snapshot_data_runs 
--( unik_key VARCHAR2( 16 CHAR) primary key 
-- , table_name_snapshot VARCHAR2(30 CHAR) NOT NULL 
-- , table_owner_origin VARCHAR2(30 CHAR) NOT NULL 
-- , table_name_origin  VARCHAR2(30 CHAR) NOT NULL 
-- , part_or_subpart_name VARCHAR2(30 CHAR) 
-- , part_hier VARCHAR2(10 CHAR) 
-- , creation_dt DATE NOT NULL 
-- , snapshot_complete_dt DATE
-- , row_cnt_backup NUMBER 
-- , filter_column VARCHAR2( 30 ) 
-- , filter_modulo NUMBER (10)
-- , tool_comments VARCHAR2(1000 char)
-- , user_comments VARCHAR2(200 char)
--)
--;


set serverout on timing on time on 

DECLARE
  lk_default_pk_column CONSTANT all_tab_columns.column_name%TYPE := 'ID';
  lk_snapshot_tech_column  CONSTANT all_tab_columns.column_name%TYPE := 'SNAPSHOT_KEY';
  lv_unik_key   snapshot_data_runs.unik_key%TYPE;
  lv_table_name_snapshot snapshot_data_runs.table_name_snapshot%TYPE;
  lv_table_name_origin snapshot_data_runs.table_name_origin%TYPE := UPPER('&pi_table_origin');
  lv_table_owner_origin snapshot_data_runs.table_owner_origin%TYPE := UPPER( '&pi_owner_origin');
  lv_part_hier   snapshot_data_runs.part_hier%TYPE := CASE WHEN '&pi_part_hier' = '?' THEN NULL ELSE UPPER( '&pi_part_hier') END;
  lv_part_or_subpart_name   snapshot_data_runs.part_or_subpart_name%TYPE := UPPER( '&pi_part_or_subpart_name');
  lv_user_comments   snapshot_data_runs.user_comments%TYPE := CASE WHEN '&pi_comments' = '?' THEN NULL ELSE '&pi_comments' END;
  lv_tool_comments snapshot_data_runs.tool_comments%TYPE ;
  lv_modulo snapshot_data_runs.filter_modulo%TYPE := 
    CASE WHEN '&pi_modulo' = '?' THEN NULL ELSE To_number( '&pi_modulo' ) END;

  lv_src_column_list VARCHAR2(4000);
  lv_select_from_clause LONG;
  lv_insert_cnt NUMBER;
  lv_seg_mb NUMBER;
  lv_default_pk_col_cnt NUMBER;
  lv_pk_example_column  all_tab_columns.column_name%TYPE;

  FUNCTION get_column_list 
  ( pi_owner VARCHAR2
   ,pi_table VARCHAR2
  ) RETURN VARCHAR2
  AS
    lv_return VARCHAR2( 4000 CHAR );
  BEGIN 
    SELECT LISTAGG( column_name,',') WITHIN GROUP (ORDER BY column_id )
    INTO lv_return
    FROM all_tab_columns
    WHERE table_name = pi_table AND owner = pi_owner ;
    RETURN lv_return;
  END;

BEGIN
  -- indirect validate if we can select from the table/view
  lv_src_column_list := get_column_list( pi_owner => lv_table_owner_origin, pi_table => lv_table_name_origin );

  -- check potential source rows 
  IF lv_modulo IS NULL THEN 
    -- assert ID as primary key column
    SELECT count(1), MAX ( col.column_name ) 
    INTO lv_default_pk_col_cnt, lv_pk_example_column 
    FROM dba_cons_columns col JOIN dba_constraints pk ON pk.owner = col.owner AND col.constraint_name = pk.constraint_name 
    WHERE col.table_name = lv_table_name_origin
      AND col.owner      = lv_table_owner_origin
      AND pk.constraint_type IN ( 'U', 'P' )
      AND col.column_name = 'ID'
      ;
    CASE 
    WHEN lv_default_pk_col_cnt = 0 THEN 
      raise_application_error( -20001, 'could not determine ID as PK column for the given table!');
    ELSE
      NULL;
    END CASE;

    CASE 
    WHEN lv_part_hier IN ( 'PART' , 'SUBPART' ) THEN 
      BEGIN 
        SELECT  bytes  / 1024/1024 seg_mb
        INTO lv_seg_mb
        FROM dba_segments 
        WHERE owner = lv_table_owner_origin
          AND segment_name  = lv_table_name_origin
          AND partition_name  = lv_part_or_subpart_name 
          AND ( segment_type = 'TABLE SUBPARTITION' AND lv_part_hier = 'SUBPART' 
              OR segment_type = 'TABLE PARTITION' AND lv_part_hier = 'PART'  )
        ; 
      EXCEPTION 
          WHEN no_data_found THEN 
            raise_application_error( -20001, 'Could not determine size of given (sub)partition!');
      END;
    WHEN lv_part_hier IS NULL THEN 
      BEGIN 
        SELECT bytes / 1024/1024 seg_mb
        INTO lv_seg_mb
        FROM dba_segments 
        WHERE owner = lv_table_owner_origin
          AND segment_name  = lv_table_name_origin
          AND segment_type = 'TABLE' 
        ; 
      EXCEPTION 
          WHEN no_data_found THEN 
            raise_application_error( -20001, 'Could not determine size of given table!');
      END;
    ELSE 
        raise_application_error( -20001, 'provide PART or SUBPART as partition hierarchy!');
    END CASE; 

    CASE 
    WHEN lv_seg_mb <= 10 THEN 
      NULL; 
    WHEN lv_seg_mb <= 100 THEN 
      lv_modulo := 7; 
    WHEN lv_seg_mb <= 1000 THEN 
      lv_modulo := 31; 
    WHEN lv_seg_mb <= 10000 THEN 
      lv_modulo := 73; 
    WHEN lv_seg_mb <= 50000 THEN 
      lv_modulo := 173; 
    ELSE
      raise_application_error( -20001, 'segment size of source table found to be '||lv_seg_mb||' MB. Please specify a (sub)partition or a module value!' ); 
    END CASE ; --check segment size 

    lv_tool_comments := 'filter modulo set to '||lv_modulo||' due to segment MB '||lv_seg_mb;

  ELSE  -- filter modulo is given 
      null;
  END IF; -- check pi_modulo 


  SELECT SUBSTR( standard_hash ( sys_guid() ), 1, 16 ) 
  INTO lv_unik_key
  FROM dual
  ;
  lv_table_name_snapshot := substr( lv_table_name_origin, 1, 25 ) ||'_'||lv_unik_key;

  INSERT INTO snapshot_data_runs 
 ( unik_key,    table_name_snapshot
  , table_owner_origin  , table_name_origin  , part_or_subpart_name  , part_hier
  , creation_dt  
  , filter_column  
  , filter_modulo
  , tool_comments
  , user_comments
  ) SELECT 
    lv_unik_key, lv_table_name_snapshot
  , lv_table_owner_origin, lv_table_name_origin, lv_part_or_subpart_name, lv_part_hier
  , sysdate
    , CASE WHEN lv_modulo IS NOT NULL THEN lk_default_pk_column END
    , lv_modulo 
  , lv_tool_comments
  , lv_user_comments
  FROM dual
  ;
  COMMIT;

  lv_select_from_clause := 
    ' SELECT '''||lv_unik_key ||''' AS ' ||lk_snapshot_tech_column
    ||' ,'||lv_src_column_list
    ||chr(10)||'FROM '||lv_table_owner_origin||'.'||lv_table_name_origin
    ||CASE 
      WHEN lv_part_hier = 'PART' THEN ' PARTITION( '||lv_part_or_subpart_name||' )'
      WHEN lv_part_hier = 'SUBPART' THEN ' SUBPARTITION( '||lv_part_or_subpart_name||' )'
      END 
    ;
  -- dbms_output.put_line( 'select from clause '||chr(10)||lv_select_from_clause );

  EXECUTE IMMEDIATE 'CREATE TABLE '||lv_table_name_snapshot||' AS '||lv_select_from_clause||' WHERE 1=0'
  ;
  IF COALESCE(lv_modulo, 0) = 0 THEN   
    EXECUTE IMMEDIATE 'INSERT /*+APPEND*/ INTO '||lv_table_name_snapshot
      ||chr(10)||lv_select_from_clause
    
    ;
    lv_insert_cnt := SQL%ROWCOUNT;
  ELSE 
    EXECUTE IMMEDIATE 'INSERT /*+APPEND*/ INTO '||lv_table_name_snapshot
      ||chr(10)||lv_select_from_clause
      ||chr(10)||'WHERE mod('||lk_default_pk_column||', :b1) = 0 '
    USING lv_modulo
    ;
    lv_insert_cnt := SQL%ROWCOUNT;
  END IF; -- check lv_modulo
  
  COMMIT;
  UPDATE snapshot_data_runs 
  SET snapshot_complete_dt = sysdate , row_cnt_backup = lv_insert_cnt
  WHERE unik_key = lv_unik_key
  ;
  COMMIT;
  dbms_output.put_line( 'Run: select count(1) from '||lv_table_name_snapshot );
END;
/