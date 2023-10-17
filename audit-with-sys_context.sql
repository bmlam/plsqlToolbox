set pages 100 lines 140
col attr format a40 
col value format a90 

-- select sum( length(attr) ) + sum( length(value) ) ,count(1)
SELECT t.* 
, '"'||lower(t.attr)||'": "'||t.value||'"' as js
FROM (
WITH prio_attr_ AS (  -- these attributes have priority to be before the buffer size can be exceeded
    SELECT column_value as attr 
    FROM TABLE ( ora_mining_varchar2_nt 
      ( 'ACTION'  , 'AUTHENTICATED_IDENTITY'   ,  'AUTHENTICATION_METHOD' 
      , 'BG_JOB_ID'   , 'CLIENT_INFO'   , 'CLIENT_PROGRAM_NAME' 
      , 'CURRENT_SCHEMA'    , 'CURRENT_USER'   ,  'DATABASE_ROLE' 
      , 'DBLINK_INFO' 
      , 'FG_JOB_ID'   , 'GLOBAL_UID' 
      , 'HOST'   , 'IDENTIFICATION_TYPE'   , 'INSTANCE'  , 'IP_ADDRESS' 
      , 'LANGUAGE'   , 'MODULE' 
      , 'NETWORK_PROTOCOL'   , 'NLS_CALENDAR'   , 'NLS_CURRENCY'   , 'NLS_DATE_FORMAT'   , 'NLS_DATE_LANGUAGE' 
      , 'NLS_TERRITORY'   , 'OS_USER'   , 'PLATFORM_SLASH' 
      , 'PROXY_ENTERPRISE_IDENTITY'   , 'PROXY_USER'   , 'SCHEDULER_JOB' 
      , 'SERVER_HOST'   , 'SERVICE_NAME'   , 'SESSION_USER' 
      , 'SESSIONID'   , 'SID',   'TERMINAL'   , 'UNIFIED_AUDIT_SESSIONID' 
      ) ) 
)
SELECT a.column_value as attr, trim(SYS_CONTEXT( 'USERENV' , a.column_value )) value 
, case  when p.attr is not null then 0 else 1 end  prio 
FROM TABLE ( ora_mining_varchar2_nt 
  ( 'ACTION'  , 'AUDITED_CURSORID'   , 'AUTHENTICATED_IDENTITY'   , 'AUTHENTICATION_DATA'   , 'AUTHENTICATION_METHOD' 
  , 'BG_JOB_ID'   , 'CDB_NAME'   , 'CLIENT_IDENTIFIER'   , 'CLIENT_INFO'   , 'CLIENT_PROGRAM_NAME' 
  , 'CON_ID'   , 'CON_NAME'   , 'CURRENT_BIND'  , 'CURRENT_EDITION_ID'   , 'CURRENT_EDITION_NAME' 
  , 'CURRENT_SCHEMA'   , 'CURRENT_SCHEMAID'   , 'CURRENT_USER'   , 'CURRENT_USERID'  , 'DATABASE_ROLE' 
  , 'DB_DOMAIN'   , 'DB_NAME'   , 'DB_SUPPLEMENTAL_LOG_LEVEL'   , 'DB_UNIQUE_NAME'   , 'DBLINK_INFO' 
  , 'ENTRYID'   , 'ENTERPRISE_IDENTITY'   , 'FG_JOB_ID'   , 'GLOBAL_CONTEXT_MEMORY'   , 'GLOBAL_UID' 
  , 'HOST'   , 'IDENTIFICATION_TYPE'   , 'INSTANCE'   , 'INSTANCE_NAME'  , 'IP_ADDRESS' 
  , 'IS_APPLY_SERVER'   , 'IS_DG_ROLLING_UPGRADE'   , 'ISDBA'   , 'LANGUAGE'   , 'MODULE' 
  , 'NETWORK_PROTOCOL'   , 'NLS_CALENDAR'   , 'NLS_CURRENCY'   , 'NLS_DATE_FORMAT'   , 'NLS_DATE_LANGUAGE' 
  , 'NLS_SORT'   , 'NLS_TERRITORY'   , 'ORACLE_HOME'   , 'OS_USER'   , 'PLATFORM_SLASH' 
  , 'POLICY_INVOKER'   , 'PROXY_ENTERPRISE_IDENTITY'   , 'PROXY_USER'   , 'PROXY_USERID'   , 'SCHEDULER_JOB' 
  , 'SERVER_HOST'   , 'SERVICE_NAME'   , 'SESSION_EDITION_ID'   , 'SESSION_EDITION_NAME'   , 'SESSION_USER' 
  , 'SESSIONID'   , 'SID'   , 'STATEMENTID'   , 'TERMINAL'   , 'UNIFIED_AUDIT_SESSIONID' 
  ) 
) a
LEFT JOIN prio_attr_ p ON a.column_value = p.attr 
) t
ORDER BY prio 
;
