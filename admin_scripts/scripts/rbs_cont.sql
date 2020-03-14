REM
REM Rollback Segments contention
REM

@_BEGIN
@_TITLE "Rollback segment contention (summary)"

COLUMN class    FORMAT A20             HEADING 'Header Type'
COLUMN count    FORMAT 999,999,999     HEADING 'Number|of Waits'

SELECT
    class,
    count(*) count
FROM
    v$waitstat
WHERE
    class IN (
        'system undo header',
        'system undo block',
        'undo header',
        'undo block')
GROUP BY
    class
/

@_TITLE "Rollback segment contention (details)"

COLUMN con_get  FORMAT 999,999,999,999 HEADING 'Logical|Reads'
COLUMN pct      FORMAT 990.99          HEADING 'Percent of|Contention'

SELECT
    a.class,
    count,
    SUM(value) con_get,
    ((count / SUM(value)) * 100) pct
FROM
    v$waitstat a,
    v$sysstat b
WHERE
    name IN ('db block gets', 'consistent gets')
    AND a.class IN (
        'system undo header',
        'system undo block',
        'undo header',
        'undo block')
GROUP BY
    a.class,
    count
/

@_END
