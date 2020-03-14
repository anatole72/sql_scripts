REM
REM  The following script provides information on the status of all blocks in 
REM  the buffer cache and lists how many of each object currently reside in
REM  the buffer cache.
REM
REM  To create the view v$bh, which is used by this script, you must run    
REM  the script $ORACLE_HOME/rdbms/admin/catparr.sql on UNIX machines. 
REM
REM  You have to re-run CATPARR.SQL prior to re-running this script.
REM

@_BEGIN
@_TITLE 'BUFFER CACHE SUMMARY'

COLUMN kind     FORMAT A12  HEADING "Type"
COLUMN name     FORMAT A49  HEADING "Object Name"
COLUMN status   FORMAT A6   HEADING "Status"
COLUMN buffers              HEADING "Buffers"

BREAK ON kind SKIP 1 ON REPORT
COMPUTE SUM LABEL Total OF buffers ON kind
COMPUTE SUM LABEL Total OF buffers ON REPORT

SELECT 
    kind, 
    username || DECODE(username, '', '', '.') || name name, 
    status, 
    COUNT(*) buffers
FROM 
    v$cache, dba_users
WHERE 
    owner# = user_id (+)
GROUP BY 
    kind, 
    username || DECODE(username, '', '', '.') || name, 
    status
;

@_TITLE 'CURRENT BUFFER CACHE USAGE'
SELECT 
    status, 
    COUNT(*) buffers 
FROM 
    v$bh 
GROUP BY 
    status
;

@_END
