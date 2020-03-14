REM
REM  This script lists all objects that the waits are 
REM  currently occurring on.
REM
REM  Author: Mark Gurry
REM

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

COLUMN nl NEWLINE
SPOOL &SCRIPT

SELECT
    '/* ' nl, 
    'USER '|| v$session.username || '(' || v$session_wait.sid || ')' nl,
     v$sqlarea.sql_text nl,
    ' */' nl,
    'SELECT segment_name, segment_type ' nl,
    'FROM dba_extents ' nl,
    'WHERE file_id = ' || v$session_wait.p1 nl,
    'AND '|| v$session_wait.p2 || ' BETWEEN block_id AND (block_id + blocks - 1) ;'
FROM 
    v$session, 
    v$sqlarea,
    v$session_wait
WHERE 
    (
        v$session_wait.event LIKE '%buffer%'
        OR v$session_wait.event LIKE '%write%'
        OR v$session_wait.event LIKE '%read%'
    )
    AND v$session_wait.sid = v$session.sid
    AND v$session.sql_address = v$sqlarea.address
    AND v$session.sql_hash_value = v$sqlarea.hash_value
/

SPOOL OFF

@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

@_END
