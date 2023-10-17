CREATE OR REPLACE FUNCTION long_substr (
    p_query     IN VARCHAR2,
    p_bind      IN VARCHAR2,
    p_from_byte IN NUMBER DEFAULT 1,
    p_for_bytes IN NUMBER DEFAULT 60
) RETURN VARCHAR2 
/* source: https://asktom.oracle.com/pls/apex/f?p=100:11:0::::P11_QUESTION_ID:426318778291
*/ 
AS
    l_cursor   INTEGER DEFAULT dbms_sql.open_cursor;
    l_long_val LONG;
    l_buflen   INTEGER;
    l_ignore   NUMBER;
BEGIN
    dbms_sql.parse(l_cursor, p_query, dbms_sql.native);
    dbms_sql.bind_variable(l_cursor, ':bv', p_bind);
    dbms_sql.define_column_long(l_cursor, 1);
    l_ignore := dbms_sql.execute(l_cursor);
    IF ( dbms_sql.fetch_rows(l_cursor) > 0 ) THEN
        dbms_sql.column_value_long(c => l_cursor, position => 1, length => p_for_bytes, offset => p_from_byte, value => l_long_val,
                                  value_length => l_buflen);
    END IF;

    RETURN l_long_val;
EXCEPTION
    WHEN OTHERS THEN
        IF dbms_sql.is_open(l_cursor) THEN
            dbms_sql.close_cursor(l_cursor);
        END IF;
        RAISE;
END;
/

SHOW ERRORS