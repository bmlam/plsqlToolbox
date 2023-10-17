rem Source: https://oracle-text-de.blogspot.com/2013/10/oracle-text-in-oracle-12c-automatic.html

SET ECHO OFF 
/*


DROP table texttabelle;

create table texttabelle(
  id          number(10) GENERATED ALWAYS AS IDENTITY,
  dokument varchar2(1000)
)
/


exec ctx_ddl.drop_preference ('my_storage');
exec ctx_ddl.create_preference('my_storage', 'BASIC_STORAGE');
exec ctx_ddl.set_attribute ('my_storage', 'STAGE_ITAB', 'true');

create index my_index on texttabelle (dokument) 
indextype is ctxsys.context
parameters( 'storage my_storage sync (on commit)')
;

SELECT table_name, cast ( o.created AS TIMESTAMP) created_ts
FROM user_tables t JOIN user_objects o ON ( o.object_name = t.table_name AND object_type = 'TABLE')
WHERE table_name LIKE 'DR$MY_INDEX$%'
ORDER BY table_name 
;

SET ECHO ON 
DESC DR$MY_INDEX$G
DESC DR$MY_INDEX$I

VBSOWNER@vbse > SELECT table_name, cast ( o.created AS TIMESTAMP) created_ts
  2  FROM user_tables t JOIN user_objects o ON ( o.object_name = t.table_name AND object_type = 'TABLE')
  3  WHERE table_name LIKE 'DR$MY_INDEX$%'
  4  ORDER BY table_name
  5  ;

TABLE_NAME                     CREATED_TS
------------------------------ ---------------------------------------------------------------------------
DR$MY_INDEX$G                  06.04.22 13:56:54,000000
DR$MY_INDEX$I                  06.04.22 13:56:53,000000
DR$MY_INDEX$K                  06.04.22 13:56:53,000000
DR$MY_INDEX$N                  06.04.22 13:56:54,000000
DR$MY_INDEX$R                  06.04.22 13:56:53,000000
DR$MY_INDEX$U                  06.04.22 13:56:54,000000

VBSOWNER@vbse > desc DR$MY_INDEX$R
 Name                                                              Null?    Typ
 ----------------------------------------------------------------- -------- --------------------------------------------
 ROW_NO                                                            NOT NULL NUMBER(5)
 DATA                                                                       BLOB
 
VBSOWNER@vbse > DESC DR$MY_INDEX$G
 Name                                      Null?    Typ
 ----------------------------------------- -------- ----------------------------
 TOKEN_TEXT                                NOT NULL VARCHAR2(64)
 TOKEN_TYPE                                NOT NULL NUMBER(10)
 TOKEN_FIRST                               NOT NULL NUMBER(10)
 TOKEN_LAST                                NOT NULL NUMBER(10)
 TOKEN_COUNT                               NOT NULL NUMBER(10)
 TOKEN_INFO                                         BLOB

VBSOWNER@vbse > DESC DR$MY_INDEX$I
 Name                                      Null?    Typ
 ----------------------------------------- -------- ----------------------------
 TOKEN_TEXT                                NOT NULL VARCHAR2(64)
 TOKEN_TYPE                                NOT NULL NUMBER(10)
 TOKEN_FIRST                               NOT NULL NUMBER(10)
 TOKEN_LAST                                NOT NULL NUMBER(10)
 TOKEN_COUNT                               NOT NULL NUMBER(10)
 TOKEN_INFO


insert into texttabelle (dokument) values 
         ('ACFLS gewinnt Wahl in Hansestadt: slfca verbucht starten Verlust bei der Wahl');
commit;
insert into texttabelle (dokument) values 
         ('Regierung schlägt Alarm: Kriminalität steigt immer weiter an. Häusliche Gewalt mal anders: Frau schlaegt Mann krankenhausreif'); 
commit;

COL token_text FORMAT A30 

SET LINES 120 PAGES 100 HEADING ON FEEDBACK ON ECHO ON 

SELECT token_text, token_type, token_first fst, token_last lst, token_count cnt FROM  dr$my_index$i ORDER BY token_text;
SELECT token_text, token_type, token_first fst, token_last lst, token_count cnt FROM  dr$my_index$g ORDER BY token_text;

VBSOWNER@vbse > select * from DR$MY_INDEX$k
  2  ;

     DOCID TEXTKEY
---------- ------------------
         1 AACuv2AAWAAELCdAAA
         2 AACuv2AAWAAELCdAAB

2 Zeilen ausgewählt.

REM exec ctx_ddl.set_attribute ('my_storage', 'G_TABLE_CLAUSE', 
REM exec ctx_ddl.set_attribute ('my_storage', 'G_INDEX_CLAUSE', 
                                                 'storage (buffer_pool keep)');

VBSOWNER@vbse > execute ctx_ddl.optimize_index(idx_name=>'MY_INDEX', optlevel=>'MERGE');

PL/SQL-Prozedur erfolgreich abgeschlossen.

VBSOWNER@vbse >
VBSOWNER@vbse > SELECT token_text, token_type, token_first fst, token_last lst, token_count cnt FROM  dr$my_index$i ORDER BY token_text;

TOKEN_TEXT                     TOKEN_TYPE        FST        LST        CNT
------------------------------ ---------- ---------- ---------- ----------
ACFLS                                   0          1          3          2
Alarm                                   0          2          2          1
anders                                  0          2          2          1
Frau                                    0          2          2          1
Gewalt                                  0          2          2          1
gewinnt                                 0          1          3          2
gt                                      0          2          2          1
HÃ                                      0          2          2          1
Hanse                                   9          1          3          2
Hansestadt                              0          1          3          2
immer                                   0          2          2          1
krankenhausreif                         0          2          2          1
KriminalitÃ                             0          2          2          1
mal                                     0          2          2          1
Mann                                    0          2          2          1
Regierung                               0          2          2          1
reif                                    9          2          2          1
schlÃ                                   0          2          2          1
schlaegt                                0          2          2          1
schlägt                                 0          2          2          1
slfca                                   0          1          3          2
Stadt                                   9          1          3          2
starten                                 0          1          3          2
steigt                                  0          2          2          1
t                                       0          2          2          1
usliche                                 0          2          2          1
verbucht                                0          1          3          2
Verlust                                 0          1          3          2
wahl                                    0          3          3          1
Wahl                                    0          1          1          1
weiter                                  0          2          2          1

31 Zeilen ausgewählt.

VBSOWNER@vbse > SELECT token_text, token_type, token_first fst, token_last lst, token_count cnt FROM  dr$my_index$g ORDER BY token_text;

Es wurden keine Zeilen ausgewählt

VBSOWNER@vbse > execute ctx_ddl.optimize_index(idx_name=>'MY_INDEX', optlevel=>'MERGE');

PL/SQL-Prozedur erfolgreich abgeschlossen.

VBSOWNER@vbse > SELECT t.*, contains ( dokument, 'Abstimmung' ) foo FROM texttabelle t WHERE contains ( dokument, 'Abstimmung' ) > 0;

        ID
----------
DOKUMENT
------------------------------------------------------------------------------------------------------------------------
       FOO
----------
         1
ACFLS gewinnt Abstimmung in Hansestadt: slfca verbucht starten Verlust bei der Abstimmung
        10


1 Zeile wurde ausgewählt.

VBSOWNER@vbse > exec ctx_ddl.add_auto_optimize( 'my_index' )
BEGIN ctx_ddl.add_auto_optimize( 'my_index' ); END;

*
FEHLER in Zeile 1:
ORA-20000: Oracle Text-Fehler:
DRG-13904: max_rows für Index/Partition auf Nicht-Nullwert eingestellt
ORA-06512: in "CTXSYS.DRUE", Zeile 171
ORA-06512: in "CTXSYS.CTX_DDL", Zeile 2237
ORA-06512: in Zeile 1

-------------------> */


SET ECHO ON

DROP table texttabelle;

create table texttabelle(
  id          number(10) GENERATED ALWAYS AS IDENTITY,
  dokument varchar2(1000)
)
/

exec ctx_ddl.drop_preference ('my_storage');
exec ctx_ddl.create_preference('my_storage', 'BASIC_STORAGE');
exec ctx_ddl.set_attribute ('my_storage', 'STAGE_ITAB', 'true');

create index my_index on texttabelle (dokument) 
indextype is ctxsys.context
parameters( 'storage my_storage sync (on commit) ASYNCHRONOUS_UPDATE ')
;

exec ctx_ddl.add_auto_optimize( 'my_index' )


insert into texttabelle (dokument) values 
         ('ACFLS gewinnt Wahl in Hansestadt: slfca verbucht starten Verlust bei der Wahl');
insert into texttabelle (dokument) values 
         ('Regierung schlägt Alarm: Kriminalität steigt immer weiter an. Häusliche Gewalt mal anders: Frau schlaegt Mann krankenhausreif'); 
commit;

SET ECHO OFF 