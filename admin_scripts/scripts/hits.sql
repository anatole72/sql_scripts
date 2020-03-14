REM 
REM  Display primary ORACLE internal hit ratios and memory
REM  (including recommended values)
REM 
REM  Author:  Mark Lang, 1998
REM 

@_BEGIN
@_TITLE "PERFORMANCE RATIOS"

COLUMN sort1    NOPRINT
COLUMN str      FORMAT A13      HEADING STRUCTURE
COLUMN value    FORMAT 0.999    HEADING RATIO
COLUMN opt      FORMAT 0.999    HEADING GOAL
COLUMN params   FORMAT A40      HEADING MEMORY

SELECT
    1 sort1,
    'Library Cache' str,
    1 - (SUM(lc.reloads) / SUM(lc.pins)) value,
    0.99 opt,
    LTRIM(TO_CHAR(MAX(p1.value) / (1024*1024), '990')) || 'M' params
FROM
    v$librarycache lc,
    v$parameter p1
WHERE
    p1.name = 'shared_pool_size'
UNION
SELECT
    2,
    'Dict Cache',
    (SUM(dc.gets) - SUM(dc.getmisses)) / SUM(dc.gets),
    0.85,
    LTRIM(TO_CHAR(MAX(p1.value) / (1024 * 1024), '990')) || 'M' params
FROM
    v$rowcache dc,
    v$parameter p1
WHERE
    p1.name = 'shared_pool_size'
UNION
SELECT
    3,
    'Buffer Cache',
    1 - (pr.value / (bg.value + cg.value)),
    0.85,
    LTRIM(TO_CHAR((p1.value * p2.value) / (1024 * 1024), '990')) || 'M ('
    || LTRIM(TO_CHAR(p2.value, '99,990')) || ' '
    || TO_CHAR(p1.value / 1024) || 'K blocks)'
FROM
    v$sysstat bg,
    v$sysstat cg,
    v$sysstat pr,
    v$parameter p1,
    v$parameter p2
WHERE
    bg.name = 'db block gets'
    AND cg.name = 'consistent gets'
    AND pr.name = 'physical reads'
    AND p1.name = 'db_block_size'
    AND p2.name = 'db_block_buffers'
UNION
SELECT
    4,
    'Sorts',
    1 - (sd.value / (sm.value + sd.value)),
    0.95,
    LTRIM(TO_CHAR(p1.value / 1024, '9,990')) || 'K/'
    || LTRIM(TO_CHAR(p2.value / 1024, '9,990')) || 'K'
FROM
    v$sysstat sm,
    v$sysstat sd, 
    v$parameter p1,
    v$parameter p2
WHERE
    sm.name = 'sorts (memory)'
    AND sd.name = 'sorts (disk)'
    AND p1.name = 'sort_area_size'
    AND p2.name = 'sort_area_retained_size'
;

@_END





