REM
REM  This script lists the CPU used per session in descending order 
REM  of CPU usage. You must have TIMED_STATISTICS = TRUE for 
REM  meaningful output.
REM
REM  Author: Mark Gurry
REM

@_BEGIN

COLUMN parameter NOPRINT;
COLUMN user_process FORMAT A30
COLUMN value FORMAT 999,999,999.99

@_TITLE 'CPU Used By Session'

SELECT 
    SUBSTR(name, 1, 30) parameter,
    ss.username || '(' || se.sid || ') ' user_process, 
    value
FROM 
    v$session ss, 
    v$sesstat se, 
    v$statname sn
WHERE  
    se.statistic# = sn.statistic#
    AND name LIKE '%CPU used by this session%'
    AND se.sid = ss.sid
    AND ss.username IS NOT NULL
ORDER BY
    SUBSTR(name, 1, 30), 
    value DESC
/
@_END


