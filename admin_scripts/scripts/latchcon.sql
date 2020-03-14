REM
REM  The report generated by the following script lists information
REM  critical to determining if a database instance is experiencing
REM  latch contention. Latch contention ratios should remain less than
REM  or equal to 1%. If a ratio column is greater than 1%, latch contention
REM  exists.   
REM 
REM  Please note the following: 
REM 
REM  When a process requests a latch, depending on the type of latch, the process 
REM  will wait and try  again later to acquire the latch. The "redo allocation" 
REM  latch is a  "willing to wait" latch. 
REM
REM  The "redo copy" latch is an "immediate" latch. Unlike the "willing to wait" 
REM  latch request, the "immediate" latch requests must be acquired instantly.
REM

@_BEGIN
@_TITLE 'LATCH CONTENTION REPORT' 
 
COLUMN name     FORMAT A29          HEADING Name
COLUMN gets     FORMAT 999,999,999  HEADING Gets
COLUMN misses   FORMAT 999.99       HEADING "Misses/|Gets%" 
COLUMN spins    FORMAT 999.99       HEADING "Spins/|Misses%"
COLUMN igets    FORMAT 999,999,999  HEADING "Immediate|Gets"
COLUMN imisses  FORMAT 999.99       HEADING "ImGets/|Misses%"
 
SELECT
    name,
    gets,
    misses * 100 / DECODE(gets, 0, 1, gets) misses, 
    spin_gets * 100 / DECODE(misses, 0, 1, misses) spins,
    immediate_gets igets,
    immediate_misses * 100 /
        DECODE(immediate_gets, 0, 1, immediate_gets) imisses 
FROM
    v$latch
WHERE
    gets + immediate_gets > 0
ORDER BY
    gets + immediate_gets DESC
/ 

@_END
