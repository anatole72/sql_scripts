REM
REM This script shows the Multi-Threaded Server waits.
REM

@_BEGIN
SELECT 
    network, 
    SUM(busy) / (SUM(busy) + SUM(idle)) "BUSY RATE"
FROM 
    v$dispatcher
GROUP BY 
    network
;
@_END
