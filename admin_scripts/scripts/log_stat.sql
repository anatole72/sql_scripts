REM
REM Shows various statistics associated with redo logs
REM

@_BEGIN
@_TITLE "REDO LOG STATISTICS"
SELECT
    a.name,
    b.value
FROM
    v$statname a,
    v$sysstat b
WHERE
    a.statistic# = b.statistic#
    AND a.name LIKE '%redo%'
ORDER BY
    a.name
/
@_END
