REM
REM  Returns a snapshot of all the wait events in the database.
REM

@_BEGIN
@_TITLE "WAIT EVENTS"

COLUMN Delay FORMAT A40

SELECT 
    COUNT(*) count,
    'DB Message Wait' Delay
FROM 
    v$session_wait w, 
    v$session s1
WHERE 
    w.sid = s1.sid
    AND w.wait_time != 0
    AND EXISTS ( 
        SELECT 1 FROM v$session s3
        WHERE s1.paddr = s3.paddr 
        AND s1.sid != s3.sid
    )
GROUP BY 
    2
UNION ALL
SELECT 
    COUNT(*) count,
    DECODE(WAIT_TIME, 
        0, DECODE(event, 
            'db file sequential read', 'Random IO (Indexed)',
            'db file scattered read', 'Sequential IO (Full Table Scan)', 
            'enqueue', 'Lock', 
            event), 
        'CPU')  Delay
FROM 
    v$session_wait w, 
    v$session s1
WHERE 
    w.sid = s1.sid
    AND (w.wait_time = 0 
        OR NOT EXISTS ( 
            SELECT 1 FROM v$session s3
	        WHERE s1.paddr = s3.paddr 
	        AND s1.sid != s3.sid
	    )
	)
GROUP BY 
    DECODE(WAIT_TIME, 
        0, DECODE(event, 
            'db file sequential read', 'Random IO (Indexed)',
            'db file scattered read', 'Sequential IO (Full Table Scan)', 
            'enqueue', 'Lock', 
             event), 
        'CPU')  
ORDER BY
    1 DESC
;

@_END
