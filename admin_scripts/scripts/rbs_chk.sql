REM
REM  This scripts lists how effectively the rollback segments have been set up.
REM       
REM  Author:  Mark Gurry
REM

@_BEGIN

SET HEADING OFF
SELECT 
    'Rollback Segments are not using dedicated tablespaces. This often hinders ' nl,
    'performance. The exact locations of this rollback segments is: '
FROM 
    DUAL
WHERE 
    0 < (
        SELECT COUNT(*) FROM dba_tablespaces
        WHERE tablespace_name IN (
            SELECT tablespace_name FROM dba_segments 
            WHERE segment_type LIKE 'RO%'
            AND tablespace_name != 'SYSTEM'
            INTERSECT
            SELECT tablespace_name FROM dba_segments 
            WHERE segment_type NOT LIKE 'RO%'
            )
    )
/

SELECT  
    'Segment ' || segment_name || ' in tablespace ' || tablespace_name 
FROM  
    dba_rollback_segs
WHERE 
    0 < (
        SELECT COUNT(*) FROM dba_tablespaces
        WHERE tablespace_name IN (
            SELECT tablespace_name FROM dba_segments 
            WHERE segment_type LIKE 'RO%'
            AND tablespace_name != 'SYSTEM'
            INTERSECT
            SELECT tablespace_name FROM dba_segments 
            WHERE segment_type NOT LIKE 'RO%'
            )
    )
/

SELECT 
    'You have had a number of rollback segment waits. Try adding '
    || SUM(DECODE(waits, 0, 0, 1)) nl,
    'rollback segments to avoid rollback header contention. '
FROM v$rollstat
HAVING SUM(DECODE(waits, 0, 0, 1)) > 0
/

@_TITLE 'Rollbacks Activity Since the Instance Started'  
SET HEADING ON
SELECT usn "ROLLBACK TABLE", Gets, Waits , xacts "ACTIVE TRANSACTIONS"
FROM v$rollstat
/

@_TITLE 'Rollbacks Waits Since the Instance Started' 
SELECT class, count 
FROM v$waitstat
WHERE class LIKE '%undo%'
/

@_END

