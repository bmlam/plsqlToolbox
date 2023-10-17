  /* replace_clob: public domain software. every serious PLSQL shop should have something similar
* see package specs
*
* Implementatoin notes:
* important: when we scan and replace the CLOB chunk by chunk, the pi_replace_from string may be
* split across 2 chunks. So it would be WRONG to do this:
*   scan and replace from position 1     to 32767 (32K - 1)
*   scan and replace from position 32767 to 65535
*   scan and replace from position 65536 to 98303
*   etc
* Suppose the CLOB is something like the result of this
*  ' banana' || RPAD( ' ', 32767 - 10, ' ' )||'banana'
* dbms_lob.instr( clob, 'banane', offset=> 10 ) should return
*     22765
* for comparison 32k is equal to
*     32768
* Our implementation must ensure that both occurrences of pi_replace_from will be replaced!
*
* We chose a different approach:
*   Find all occurrences positions of pi_replace_from and store it in a collection variable
*   With the help of these occurrence positions, we proceed to do iteratively:
*    Copy portion which does not need to be replaced to the new CLOB
*    Append pi_replace_to to the new CLOB
*  Copy last portion which does not need to be replaced to the new CLOB
*/
CREATE OR REPLACE FUNCTION replace_clob(pi_src_clob IN CLOB, pi_replace_from IN VARCHAR2, pi_replace_to IN VARCHAR2)
    RETURN CLOB
  IS
    lv_scan_from     INTEGER := 1;
    lv_pos_found     INTEGER;
    lv_copy_len      INTEGER;
    lv_copy_from     INTEGER := 1;
    lv_dest_curr_pos INTEGER := 1;
    lv_clob_len      INTEGER;
    ltab_found_pos   ora_mining_number_nt := ora_mining_number_nt();
    lv_return        CLOB;
  BEGIN
    lv_clob_len := DBMS_LOB.getlength(pi_src_clob);

    -- Collect all occurrences of pi_replace_from
    DBMS_OUTPUT.put_line(
         $$plsql_unit
      || ':'
      || $$plsql_line
      || ' pi_replace_from '
      || pi_replace_from
      || ' pi_replace_to '
      || pi_replace_to);
    DBMS_OUTPUT.put_line(
      $$plsql_unit || ':' || $$plsql_line || ' scan from ' || lv_scan_from || ' lv_clob_len ' || lv_clob_len);

    WHILE lv_scan_from <= lv_clob_len
    LOOP
      lv_pos_found := DBMS_LOB.INSTR(pi_src_clob, pi_replace_from, offset => lv_scan_from);
      DBMS_OUTPUT.put_line($$plsql_unit || ':' || $$plsql_line || ' lv_pos_found ' || lv_pos_found);

      IF lv_pos_found > 0
      THEN
        ltab_found_pos.EXTEND;
        ltab_found_pos(ltab_found_pos.COUNT) := lv_pos_found;
        lv_scan_from                         := lv_pos_found + LENGTH(pi_replace_from) - 1;
        DBMS_OUTPUT.put_line($$plsql_unit || ':' || $$plsql_line || ' scan from ' || lv_scan_from);
      ELSE
        DBMS_OUTPUT.put_line($$plsql_unit || ':' || $$plsql_line || ' scan from ' || lv_scan_from);
        lv_scan_from := lv_clob_len + 1; -- set termination condition
      END IF;
    END LOOP;

    DBMS_OUTPUT.put_line($$plsql_unit || ':' || $$plsql_line || ' occurrence ' || ltab_found_pos.COUNT);

    --initalize the new  clob
    DBMS_LOB.createtemporary(lv_return, TRUE);

    IF ltab_found_pos.COUNT = 0
    THEN
      lv_return := pi_src_clob;
      DBMS_OUTPUT.put_line($$plsql_unit || ':' || $$plsql_line || ' return len ' || DBMS_LOB.getlength(lv_return));
    ELSE
      lv_copy_from := 1;

      FOR i IN 1 .. ltab_found_pos.COUNT
      LOOP
        -- copy stuff not subjected to replacement
        IF lv_copy_from < ltab_found_pos(i)
        THEN
          lv_copy_len      := ltab_found_pos(i) - lv_copy_from;
          DBMS_OUTPUT.put_line(
            $$plsql_unit || ':' || $$plsql_line || ' lv_copy_from ' || lv_copy_from || ' lv_copy_len ' || lv_copy_len);
          DBMS_OUTPUT.put_line($$plsql_unit || ':' || $$plsql_line || ' lv_dest_curr_pos ' || lv_dest_curr_pos);
          DBMS_LOB.COPY(src_lob     => pi_src_clob
                      , dest_lob    => lv_return
                      , amount      => lv_copy_len
                      , src_offset  => lv_copy_from
                      , dest_offset => lv_dest_curr_pos);
          lv_copy_from     := lv_copy_from + lv_copy_len;
          lv_dest_curr_pos := lv_dest_curr_pos + lv_copy_len;
        END IF;

        DBMS_LOB.writeappend(lv_return, amount => LENGTH(pi_replace_to), buffer => pi_replace_to);
        lv_dest_curr_pos := lv_dest_curr_pos + LENGTH(pi_replace_to);
        lv_copy_from     := lv_copy_from + LENGTH(pi_replace_from);

        DBMS_OUTPUT.put_line(
             $$plsql_unit
          || ':'
          || $$plsql_line
          || ' lv_copy_from '
          || lv_copy_from
          || ' lv_dest_curr_pos '
          || lv_dest_curr_pos);
        DBMS_OUTPUT.put_line($$plsql_unit || ':' || $$plsql_line || ' return len ' || DBMS_LOB.getlength(lv_return));
      END LOOP; -- over found occurrences

      IF lv_copy_from < lv_clob_len
      THEN
        lv_copy_len := lv_clob_len - lv_copy_from + 1;
        DBMS_LOB.COPY(src_lob     => pi_src_clob
                    , dest_lob    => lv_return
                    , amount      => lv_copy_len
                    , src_offset  => lv_copy_from
                    , dest_offset => lv_dest_curr_pos);
      END IF; -- check need to copy the tail
    END IF; -- check ltab_found_pos

    DBMS_OUTPUT.put_line($$plsql_unit || ':' || $$plsql_line || ' return len ' || DBMS_LOB.getlength(lv_return));

    RETURN lv_return;
  EXCEPTION
    WHEN OTHERS
    THEN
      RAISE;
  END ;
/
show errors
