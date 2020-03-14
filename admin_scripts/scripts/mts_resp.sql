REM
REM This script shows the Multi-Threaded Server response times.
REM

@_BEGIN
SELECT 
    network, 
    DECODE (
        SUM(totalq), 
        0 , 'no responses',
        SUM(wait) / SUM(totalq) || ' 100ths secs'
    ) "AVERAGE WAIT"
FROM 
    v$queue q, 
    v$dispatcher d
WHERE 
    q.type = 'DISPATCHER'
    AND q.paddr = d.paddr
GROUP BY 
    network
;
@_END
