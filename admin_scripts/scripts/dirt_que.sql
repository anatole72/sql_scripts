REM
REM  This script lists the Dirty Queue Length. The longer the queue length, 
REM  the more trouble the DBWR is having keeping up.
REM    
REM  Author: Mark Gurry
REM

@_BEGIN
@_TITLE 'Average Length of Write Request Queue'

COLUMN "Write Request Length" FORMAT 999,999.99

SELECT 
    SUM(DECODE(name, 'summed dirty queue length', value)) /
    SUM(DECODE(name, 'write requests', value)) "Dirty Queue Length"
FROM 
    v$sysstat
WHERE  
    name IN ('summed dirty queue length' ,'write requests')
    AND value > 0
/
@_END



