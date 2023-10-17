SET ECHO ON 

CREATE TABLE test_interval_parts
    ( prod_id        NUMBER(6)
    , cust_id        NUMBER
    , time_id        DATE
    ) 
  PARTITION BY RANGE (time_id) 
  INTERVAL(NUMTOYMINTERVAL(1, 'MONTH'))
    ( PARTITION p0 VALUES LESS THAN (TO_DATE('01-11-2021', 'DD-MM-YYYY'))
     ,PARTITION p1 VALUES LESS THAN (TO_DATE('01-12-2021', 'DD-MM-YYYY'))
     ,PARTITION p2 VALUES LESS THAN (TO_DATE('01-01-2022', 'DD-MM-YYYY'))
    );
    
PROMPT Daten in allen partitionen inserten     
INSERT INTO test_interval_parts  select object_id, object_id, TO_DATE('10-10-2021', 'DD-MM-YYYY') from user_objects WHERE rownum <= 2;
INSERT INTO test_interval_parts  select object_id, object_id, TO_DATE('11-11-2021', 'DD-MM-YYYY') from user_objects WHERE rownum <= 2;
INSERT INTO test_interval_parts  select object_id, object_id, TO_DATE('12-12-2021', 'DD-MM-YYYY') from user_objects WHERE rownum <= 2;

COMMIT;

REM  Aelteste Partition droppen 
ALTER TABLE test_interval_parts DROP PARTITION p0;

REM  Abfrage zeigt, dass Nov-21 Partiton weg ist
select to_char( time_id, 'yyyy.mm.dd' ) part_key, count(1) from test_interval_parts group by to_char( time_id, 'yyyy.mm.dd' ) ORDER BY 1;

REM  Neue Daten für Jan 21 inserten, neue Partition wird automatisch angelegt
INSERT INTO test_interval_parts  select object_id, object_id, TO_DATE('01-01-2022', 'DD-MM-YYYY') from user_objects WHERE rownum <= 2;

COMMIT;

REM  Abfrage zeigt, dass neue partition da ist 
select to_char( time_id, 'yyyy.mm.dd' ) part_key, count(1) from test_interval_parts group by to_char( time_id, 'yyyy.mm.dd' ) ORDER BY 1;
