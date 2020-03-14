REM 
REM Generate value for current session memory usage
REM 

@_BEGIN
@_TITLE 'CURRENT SESSION MEMORY'

COLUMN username FORMAT A16              HEADING Username
COLUMN memory   FORMAT 999,999,999.0    HEADING "Memory (Kb)"

SELECT 
    NVL(username,'Background') username, 
    sess.sid, 
    SUM(value) / 1024 memory
FROM 
    v$session sess, 
    v$sesstat stat, 
    v$statname name
WHERE 
    sess.sid = stat.sid
    AND stat.statistic# = name.statistic#
    AND name.name LIKE 'session % memory'
GROUP BY 
    username, 
    sess.sid
/
@_END
