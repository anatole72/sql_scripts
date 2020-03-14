REM
REM The following script lists how much of the sorting was done in memory
REM and how much sorting has not fit into the user's SORT_AREA_SIZE and
REM has been required to be done on disk.
REM

@_BEGIN
@_TITLE "SORTS STATISTICS"

COLUMN r                    HEADING "Sorted|Rows"
COLUMN m                    HEADING "Memory|Sorts"
COLUMN d                    HEADING "Disk|Sorts"
COLUMN pct  FORMAT 990.00   HEADING "Disk|%"        
COLUMN comm FORMAT A26      HEADING "Comment"       
COLUMN p    FORMAT A14      HEADING "SORT_AREA_SIZE" 

SELECT
    r.value r,
    m.value m,
    d.value d,
    DECODE(m.value, 0, 1, d.value / m.value * 100) pct,
    DECODE(SIGN(DECODE(m.value, 0, 1, d.value / m.value) - 0.05),
        1, 'Increase SORT_AREA_SIZE',
        'OK') comm,
    p.value p
FROM 
    v$sysstat r, v$sysstat m, v$sysstat d, v$parameter p
WHERE
    r.name = 'sorts (rows)'
    AND m.name = 'sorts (memory)'
    AND d.name = 'sorts (disk)'
    AND p.name = 'sort_area_size'
;

@_END
