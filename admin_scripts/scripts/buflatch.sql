REM
REM  This script shows the latch contention on the Oracle Buffer Cache.
REM  Be sure to take adavantage of the mutiple LRU latches by setting the
REM  DB_BLOCK_LRU_LATCHES parameter if you are using Oracle7.3 or later. 
REM
REM  Author:  Mark Gurry
REM

@_BEGIN
@_TITLE "Oracle Buffer Cache Latch Contention"

SELECT 
    SUBSTR(name, 1, 25) name, 
    gets, 
    misses,
    immediate_gets, 
    immediate_misses 
FROM 
    v$latch 
WHERE 
    (misses > 0 OR immediate_misses > 0)
    AND name LIKE 'cache bu%'
/
@_END
