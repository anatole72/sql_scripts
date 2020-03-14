REM
REM  This script shows the Multi-Threaded Server average wait details
REM

@_BEGIN
@_TITLE "MULTI-THREADED SERVER AVERAGE WAIT TIME"
SELECT 
    DECODE (totalq, 
        0, 'No requests',
        wait / totalq || ' 100ths secs'
    ) "AVERAGE WAIT"
FROM 
    v$queue
WHERE
    type = 'COMMON'
;
@_END
