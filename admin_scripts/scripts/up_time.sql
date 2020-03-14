REM
REM  The script calculates the time that the database started.
REM

@_BEGIN
@_TITLE "DATABASE STARTUP TIME"

COLUMN startup_time FORMAT A20
COLUMN created      FORMAT A11

SELECT
   db.name database,
   TO_CHAR(TO_DATE(SUBSTR(db.created, 1, 8), 'MM/DD/YY'), 
       'DD-MON-YYYY') created,
   th.instance,
   TO_CHAR(TO_DATE(d.value, 'J'), 'DD-MON-YYYY') || ' ' ||
       TO_CHAR(TO_DATE(s.value, 'SSSSS'), 'HH24:MI:SS') startup_time
FROM
   v$instance d,
   v$instance s,
   v$database db,
   v$thread th
WHERE
   d.key = 'STARTUP TIME - JULIAN'
   AND s.key = 'STARTUP TIME - SECONDS'
;

@_END
