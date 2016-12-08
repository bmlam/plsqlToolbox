CREATE OR REPLACE FUNCTION QWHAT_IS ( i_q_object_name VARCHAR2 )
   RETURN VARCHAR2
   AUTHID CURRENT_USER
AS
   /*
   * $Id: $
   * $HeadURL:$
   */
   normal_exit exception;
   --    l_object_type        all_objects.object_type%type;
   l_inp_name     all_users.username%TYPE;
   l_inp_owner    all_users.username%TYPE;
   l_syn_owner    all_users.username%TYPE;
   --    l_connect_user       all_users.username%type;
   --
   l_resolved_db_link all_db_links.db_link%TYPE;
   l_resolved_name all_objects.object_name%TYPE;
   l_resolved_owner all_objects.owner%TYPE;
   l_resolved_type all_objects.object_type%TYPE;
   --
   l_dot_pos      INTEGER;
   --
   l_return       VARCHAR2 ( 4000 );
   l_syn_exists   INTEGER;
   g_step         NUMBER;
   l_comment      all_tab_comments.comments%TYPE;

   PROCEDURE resolve_object ( p_name                VARCHAR2
                            , p_owner               VARCHAR2
                            , p_type1               VARCHAR2
                            , p_type2               VARCHAR2 DEFAULT NULL
                            , p_type3               VARCHAR2 DEFAULT NULL
                            --
                            , po_name        IN OUT VARCHAR2
                            , po_owner       IN OUT VARCHAR2
                            , po_type        IN OUT VARCHAR2--
                              )
   IS
      l_name         all_objects.object_name%TYPE;
      l_owner        all_objects.owner%TYPE;
      l_type         all_objects.object_type%TYPE;
   BEGIN
      SELECT owner
           , object_type
           , object_name
        INTO l_owner
           , l_type
           , l_name
        FROM all_objects
       WHERE 1 = 1
         AND owner = p_owner
         AND object_name = p_name
         AND ( object_type = p_type1
           OR ( p_type2 IS NOT NULL
           AND object_type = p_type2 )
           OR ( p_type3 IS NOT NULL
           AND object_type = p_type3 ) )
         AND ROWNUM = 1;

      po_owner    := l_owner;
      po_name     := l_name;
      po_type     := l_type;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
   END resolve_object;

   FUNCTION is_synonymed ( p_name          VARCHAR2
                         , p_owner         VARCHAR2
                         , p_syn_owner     VARCHAR2 )
      RETURN BOOLEAN
   IS
      l_cnt          INTEGER;
   BEGIN
      SELECT COUNT ( * )
        INTO l_cnt
        FROM all_synonyms
       WHERE 1 = 1
         AND table_owner = p_owner
         AND table_name = p_name
         AND synonym_name = table_name
         AND ( owner = 'PUBLIC'
           OR owner = p_syn_owner );

      RETURN l_cnt > 0;
   END is_synonymed;

   /*********************************************/
   PROCEDURE i$return ( p_msg VARCHAR2 )
   AS
   BEGIN
      l_return    := p_msg;
      RAISE normal_exit;
   END i$return;
/*********************************************/
BEGIN
   l_dot_pos   :=
      INSTR ( i_q_object_name
            , '.' );

   IF l_dot_pos > 0 THEN
      l_inp_owner :=
         TRIM ( SUBSTR ( i_q_object_name
                       , 1
                       , l_dot_pos - 1 ) );
      l_inp_name  :=
         SUBSTR ( i_q_object_name
                , l_dot_pos + 1 );
   ELSE
      l_inp_name  := TRIM ( i_q_object_name );
      l_inp_owner := USER;
   END IF; -- check dot as delimiter between owner and object

   g_step      := 88;
   dbms_output.put_line ( 27 || ':' || l_inp_name || ' of ' || l_inp_owner );
   /* Try with Table/View in assumed Schema
   */
   resolve_object ( p_owner     => l_inp_owner
                  , p_name      => l_inp_name
                  , p_type1     => 'TABLE'
                  , p_type2     => 'VIEW'
                  , p_type3     => 'FUNCTION'
                  --
                  , po_name     => l_resolved_name
                  , po_owner    => l_resolved_owner
                  , po_type     => l_resolved_type );
   g_step      := 98;
   dbms_output.put_line ( 111 || ' po_name:' || l_resolved_name || ' po_type ' || l_resolved_type );

   IF l_resolved_type IN ('TABLE', 'VIEW', 'FUNCTION') THEN
      i$return (   l_resolved_type
                || ' is owned by '
                || l_resolved_owner
                || '. Object is '
                || CASE
                      WHEN NOT is_synonymed ( p_owner     => l_resolved_owner
                                            , p_name      => l_resolved_name
                                            , p_syn_owner => l_inp_owner ) THEN
                         ' not '
                   END
                || 'synonymed' );
   END IF; -- check tab/vw/func

   /* Try with public or private Synonym
   */
   g_step      := 123;

   SELECT owner
        , table_name
        , table_owner
        , db_link
     INTO l_syn_owner
        , l_resolved_name
        , l_resolved_owner
        , l_resolved_db_link
     FROM (   SELECT owner
                   , table_name
                   , table_owner
                   , db_link
                FROM ( SELECT owner
                            , table_name
                            , table_owner
                            , db_link
                            , CASE owner
                                 WHEN 'PUBLIC' THEN 9
                                 WHEN l_inp_owner THEN 1
                              END
                                 rank_by_owner
                         FROM all_synonyms
                        WHERE 1 = 1
                          AND synonym_name = l_inp_name
                          AND ( owner = 'PUBLIC'
                            OR owner = l_inp_owner ) )
            ORDER BY rank_by_owner )
    WHERE ROWNUM = 1;

   g_step      := 138;
   resolve_object ( p_owner     => l_resolved_owner
                  , p_name      => l_resolved_name
                  , p_type1     => 'TABLE'
                  , p_type2     => 'VIEW'
                  , p_type3     => 'FUNCTION'
                  --
                  , po_name     => l_resolved_name
                  , po_owner    => l_resolved_owner
                  , po_type     => l_resolved_type );
   -- synonym will not be resolved further
   l_return    :=
         i_q_object_name
      || ' is '
      || CASE WHEN l_syn_owner IS NOT NULL THEN 'SYNONYM' ELSE l_resolved_type || ' ' || l_resolved_name END
      || ' owned by '
      || CASE WHEN l_syn_owner IS NOT NULL THEN l_syn_owner ELSE l_resolved_owner END
      || CASE
            WHEN l_syn_owner IS NOT NULL THEN
                  ' pointing to '
               || l_resolved_type
               || ' '
               || l_resolved_owner
               || '.'
               || l_resolved_name
               || CASE WHEN l_resolved_db_link IS NOT NULL THEN '@' || l_resolved_db_link END
         END;

   IF l_resolved_type IN ('VIEW', 'TABLE') THEN
      BEGIN
         SELECT comments
           INTO l_comment
           FROM all_tab_comments
          WHERE owner = l_resolved_owner
            AND table_name = l_resolved_name;

         l_return    := l_return || ' Comment on object is: ' || l_comment;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END get_comment;
   END IF; -- check is view or table

   i$return ( l_return );
   RAISE normal_exit;
EXCEPTION
   WHEN normal_exit THEN
      RETURN 'Step= ' || g_step || ' ' || l_return;
   WHEN NO_DATA_FOUND THEN
      RETURN 'No_data_found while trying to resolve ' || i_q_object_name || ' Last step was ' || g_step;
END;
/
show errors

