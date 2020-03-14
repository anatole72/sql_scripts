REM
REM  This script lists all waits that are currently occurring on the
REM  system with counts of how many times each wait has occurred.
REM

@_BEGIN
@_TITLE "SESSION WAITS (TOTAL)"

SELECT 
    event, 
    count(*) count
FROM 
    v$session_wait
GROUP BY 
    event
ORDER BY
    count(*) DESC
;

@_END
