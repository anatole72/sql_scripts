REM
REM  Dictionary cache information
REM

@_BEGIN
@_TITLE "Dictionary cache"

COLUMN parameter    FORMAT A20      HEADING Parameter
COLUMN gets                         HEADING Gets
COLUMN misses                       HEADING Get|Misses
COLUMN ratio        FORMAT 990.9    HEADING "Ratio|(%)"
COLUMN count                        HEADING Count
COLUMN usage                        HEADING Usage
COLUMN capacity     FORMAT 990.9    HEADING "Capaci|ty (%)"
COLUMN bad          FORMAT A4       HEADING "Bad?"

SELECT 
    parameter, 
    gets, 
    getmisses misses, 
    DECODE(gets, 0, 0, 100 * getmisses / gets) ratio,
    count, 
    usage, 
    DECODE(count, 0, 0, 100 * usage / count) capacity,
    DECODE(SIGN(getmisses - count), 1, 'BAD', '   ') bad
FROM   
    sys.v_$rowcache
UNION ALL
SELECT
    '{TOTAL}', 
    SUM(gets), 
    SUM(getmisses) misses, 
    100 * SUM(getmisses) / SUM(gets) ratio,
    SUM(count), 
    SUM(usage), 
    SUM(usage) / SUM(count) capacity,
    DECODE(SIGN(SUM(getmisses) / SUM(gets) - 0.15), 1, 'BAD', '   ') bad
FROM
    sys.v_$rowcache
ORDER BY
    parameter
/

PROMPT
PROMPT GETS      - Total number of requests for information on the data object
PROMPT GETMISSES - Number of data requests resulting in cache misses
PROMPT COUNT     - Total number of entries in the cache
PROMPT USAGE     - Number of cache entries that contain valid data

PROMPT
PROMPT ORACLE7 PERFORMANCE TUNING
PROMPT ==========================
PROMPT The ratio of all GETMISSES to all GETS should be less than 15%, during
PROMPT normal running. If it is higher, consider increasing SHARED_POOL_SIZE.
PROMPT
PROMPT If the GETMISSES exceeds the COUNT by a significant margin, you may
PROMPT need to increase your SHARED_POOL_SIZE too.

@_END

