REM
REM  Reports dictionary cache parameter effectiveness.  It recommends 
REM  an action based on maintaining more than 80% usage ofthe available 
REM  cache entries while encountering cache misses no more than 10% of 
REM  the time. 
REM  

@_BEGIN
@_TITLE 'DICTIONARY CACHE STATISTICS' 
 
COLUMN parameter HEADING 'Parameter Name'    FORMAT A21 TRUNC 
COLUMN count     HEADING 'Entries|Allocated' FORMAT 9999990  
COLUMN usage     HEADING 'Entries|Used'      FORMAT 9999990  
COLUMN gets      HEADING 'Gets'              FORMAT 9999990  
COLUMN getmisses HEADING 'Get|Misses'        FORMAT 9999990  
COLUMN pctused   HEADING 'Pct|Used'          FORMAT 990.0 
COLUMN pctmisses HEADING 'Pct|Misses'        FORMAT 990.0 
COLUMN action    HEADING 'Rec''d|Action'     FORMAT A6 
 
SELECT 
    parameter, 
    count, 
    usage, 
    100 * NVL(usage, 0) / DECODE(count, NULL, 1, 0, 1, count) pctused, 
    gets, 
    getmisses, 
    100 * NVL(getmisses, 0) / DECODE(gets, NULL, 1, 0, 1, gets) pctmisses, 
    DECODE( 
        GREATEST(100 * NVL(usage, 0) / DECODE(count, NULL, 1, 0, 1, count), 80), 
        80, ' Lower', 
        DECODE(
            LEAST(100 * NVL(getmisses, 0) / DECODE(gets, NULL, 1, 0, 1, gets), 10), 
            10, '*Raise',
            ' Ok'
        ) 
    ) action 
FROM 
    v$rowcache 
ORDER BY 
    1 
/

@_END 
