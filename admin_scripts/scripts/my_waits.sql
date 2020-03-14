REM
REM  Returns the cummulative totals for all wait events
REM  for the current session.
REM

@_BEGIN
@_TITLE "CURRENT SESSION WAITS"

COLUMN DELAY        FORMAT A40
COLUMN SECONDS      FORMAT 999990.99
COLUMN PER_EVENT    FORMAT 9990.9999

SELECT
    DECODE(event, 
        'db file sequential read', 'Random IO (Indexed)',
        'db file scattered read', 'Sequential IO (Full Table Scan)',
        'enqueue', 'Lock',
        event
    ) Delay,
    TOTAL_WAITS, 
    DECODE(SIGN(TIME_WAITED - 4200000000), 
        1, -999, 
        TIME_WAITED/100) Seconds,
        DECODE(SIGN(TIME_WAITED - 4200000000), 
            1, -999, 
            TIME_WAITED / (100 * TOTAL_WAITS)) Per_Event
FROM 
    v$session_event se 
WHERE 
    sid = (SELECT s.sid FROM v$session s
           WHERE audsid = userenv('SESSIONID')) 
ORDER BY 
    3 DESC
;
@_END
