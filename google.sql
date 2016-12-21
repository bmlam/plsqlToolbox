CREATE OR REPLACE FUNCTION GOOGLE (
   p_pattern                           VARCHAR2
	, p_ignore_case INTEGER default 1
)
   RETURN CLOB AUTHID CURRENT_USER AS
   /* List all entries in user_objects matching the given pattern
   */
   l_rc_clob   CLOB;
   l_cnt       NUMBER := 0;
BEGIN
   FOR rec IN (SELECT   o.*
                   FROM user_objects o
                  WHERE 1=1 
                    AND (p_ignore_case > 0 AND UPPER(object_name)  LIKE UPPER (p_pattern) 
							OR object_name  LIKE p_pattern
						  )
                    AND object_type NOT IN
                            ('TABLE PARTITION', 'TABLE SUBPARTITION', 'INDEX PARTITION', 'INDEX SUBPARTITION', 'INDEX')
               ORDER BY object_type
                      , object_name) LOOP
      l_cnt := l_cnt + 1;
      l_rc_clob :=
            CASE
               WHEN l_cnt > 1 THEN l_rc_clob || CHR (10)
            END
         || lPAD (l_cnt, 3)
         || ': '
         || RPAD (rec.object_type, 20)
         || ' '
         || RPAD (rec.object_name, 30);
   END LOOP;   -- over objects

   l_rc_clob := 'Objects found: ' || l_cnt || CHR (10) || l_rc_clob;
   RETURN l_rc_clob;
END;
/

show error

grant execute on google to bic_lib, dw, dw_cl, nba_prof ;
