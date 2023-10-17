CREATE OR REPLACE PROCEDURE print_table (
    p_query      IN VARCHAR2,
    p_date_fmt   IN VARCHAR2 DEFAULT 'dd-mon-yyyy hh24:mi:ss'
)
-- this utility is designed to be installed ONCE in a database and used
-- by all. Also,it is nice to have roles enabled so that queries by
-- DBA's that use a role to gain access to the DBA_* views still work
-- that is the purpose of AUTHID CURRENT_USER
    AUTHID current_user
IS

    l_thecursor     INTEGER DEFAULT dbms_sql.open_cursor;
    l_columnvalue   VARCHAR2(4000);
    l_status        INTEGER;
    l_desctbl       dbms_sql.desc_tab;
    l_colcnt        NUMBER;
    l_cs            VARCHAR2(255);
    l_date_fmt      VARCHAR2(255);
    l_row_no        NUMBER := 0;

-- small inline procedure to restore the sessions state
-- we may have modified the cursor sharing and nls date format
-- session variables,this just restores them

    PROCEDURE restore
        IS
    BEGIN
        IF
            (
                upper(l_cs) NOT IN (
                    'FORCE','SIMILAR'
                )
            )
        THEN
            EXECUTE IMMEDIATE 'alter session set cursor_sharing=exact';
        END IF;

        IF
            (
                p_date_fmt IS NOT NULL
            )
        THEN
            EXECUTE IMMEDIATE 'alter session set nls_date_format=''' || l_date_fmt || '''';
        END IF;

        dbms_sql.close_cursor(l_thecursor);
    END restore;

BEGIN
-- I like to see the dates print out with times,by default,the
-- format mask I use includes that. In order to be “friendly�?
-- we save the date current sessions date format and then use
-- the one with the date and time. Passing in NULL will cause
-- this routine just to use the current date format
    IF
        (
            p_date_fmt IS NOT NULL
        )
    THEN
        SELECT
            sys_context(
                'userenv',
                'nls_date_format'
            )
        INTO
            l_date_fmt
        FROM
            dual;

        EXECUTE IMMEDIATE 'alter session set nls_date_format=''' || p_date_fmt || '''';
    END IF;

-- to be bind variable friendly on this ad-hoc queries,we
-- look to see if cursor sharing is already set to FORCE or
-- similar,if not,set it so when we parse — literals
-- are replaced with binds
$IF $$got_get_param_priv = 1 $THEN
    IF dbms_utility.get_parameter_value(
            'cursor_sharing',
            l_status,
            l_cs
        ) = 1 
    THEN
        IF
            (
                upper(l_cs) NOT IN (
                    'FORCE','SIMILAR'
                )
            )
        THEN
            EXECUTE IMMEDIATE 'alter session set cursor_sharing=force';
        END IF;

    END IF;
$END

-- parse and describe the query sent to us. we need
-- to know the number of columns and their names.

    dbms_sql.parse(
        l_thecursor,
        p_query,
        dbms_sql.native
    );
    dbms_sql.describe_columns(
        l_thecursor,
        l_colcnt,
        l_desctbl
    );

-- define all columns to be cast to varchar2's,we
-- are just printing them out
    FOR i IN 1..l_colcnt LOOP
        IF          l_desctbl(i).col_type NOT IN (                    113                )
        THEN
            dbms_sql.define_column(
                l_thecursor,
                i,
                l_columnvalue,
                4000
            );
        END IF;
    END LOOP;

-- execute the query,so we can fetch

    l_status := dbms_sql.execute(l_thecursor);

-- loop and print out each column on a separate line
-- bear in mind that dbms_output only prints 255 characters/line
-- so we'll only see the first 200 characters by my design…
    WHILE ( dbms_sql.fetch_rows(l_thecursor) > 0 ) LOOP
        l_row_no := l_row_no + 1;
        dbms_output.put_line('======================================= RECORD '||l_row_no );
        FOR i IN 1..l_colcnt LOOP
            IF                    l_desctbl(i).col_type NOT IN (                        113                    )
            THEN
                dbms_sql.column_value(
                    l_thecursor,
                    i,
                    l_columnvalue
                );
                dbms_output.put_line(rpad(
                    l_desctbl(i).col_name,
                    30
                )
                 || ': '
                 || substr(
                    l_columnvalue,
                    1,
                    200
                ) );

            END IF;
        END LOOP;

    END LOOP;

-- now,restore the session state,no matter what

    restore;
EXCEPTION
    WHEN OTHERS THEN
        restore;
        RAISE;
END;
/

SHOW ERRORS