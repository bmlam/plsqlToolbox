define pi_unik_key=&1

-- CREATE TABLE lam_dyn_sql ( insert_ts DATE  DEFAULT SYSDATE NOT NULL, os_user VARCHAR2(20 char), program_id VARCHAR(50 char), sql_text CLOB );




SET SERVEROUT ON  LONGCHUNKSIZE 4000   LONGSIZE 4000 LINESIZE 150 PAGES 100


DECLARE
  lk_default_pk_column CONSTANT all_tab_columns.column_name%TYPE := 'ID';
  lk_script_name       CONSTANT lam_dyn_sql.program_id%TYPE := 'snapshot_create_ua_view.sql';

  lv_unik_key  snapshot_data_runs.unik_key%TYPE := '&pi_unik_key';
  lr_run_info snapshot_data_runs%ROWTYPE;

  lv_src_column_list VARCHAR2(4000);
  lv_select_from_clause_1 LONG;
  lv_select_from_clause_2 LONG;

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
    WHERE table_name = pi_table AND owner = pi_owner 
    ;
    RETURN lv_return;
  END;

BEGIN
  
  SELECT *
  INTO lr_run_info
  FROM snapshot_data_runs
  WHERE unik_key = lv_unik_key
  ;

  lv_src_column_list := get_column_list( pi_owner => lr_run_info.table_owner_origin, pi_table => lr_run_info.table_name_origin );

  lv_select_from_clause_1 := 
    ' SELECT ''origin'' ' ||'SRC' 
    ||' ,'||lv_src_column_list
    ||chr(10)||'FROM '||lr_run_info.table_owner_origin||'.'||lr_run_info.table_name_origin
    ||CASE 
      WHEN lr_run_info.part_hier = 'PART' THEN ' PARTITION( '||lr_run_info.part_or_subpart_name||' )'
      WHEN lr_run_info.part_hier = 'SUBPART' THEN ' SUBPARTITION( '||lr_run_info.part_or_subpart_name||' )'
      END 
    ||CASE WHEN lr_run_info.filter_modulo IS NOT NULL THEN chr(10)||'WHERE mod( '||lk_default_pk_column||', '||lr_run_info.filter_modulo||' ) = 0 ' 
      END 
    ;
  lv_select_from_clause_2 := 
    ' SELECT ''snapsh'' ' ||'SRC' 
    ||' ,'||lv_src_column_list
    ||chr(10)||'FROM '||lr_run_info.table_name_snapshot
    ;

  INSERT INTO lam_dyn_sql 
  ( os_user, program_id 
    ,sql_text 
  )
  SELECT sys_context( 'userenv', 'os_user')    , lk_script_name 
    , 'WITH ua_ AS (' ||chr(10)
        ||lv_select_from_clause_1 ||chr(10)||'UNION ALL'||chr(10)||lv_select_from_clause_2 
        ||chr(10)||' ) '
        ||chr(10)||'SELECT * FROM ua_ '
  FROM dual;
  COMMIT;
END;
/