REM
REM  Total sessions UGA and PGA memory usage
REM

@_BEGIN
@_TITLE "TOTAL MEMORY FOR ALL SESSIONS"

COLUMN name FORMAT A22          HEADING Memory
COLUMN kb   FORMAT 999,999,999  HEADING "Total (Kb)"
COLUMN ma   FORMAT 999,999,999  HEADING "Max (Kb)"
COLUMN mi   FORMAT 999,999,999  HEADING "Min (Kb)"
COLUMN se   FORMAT 9999         HEADING "Sessions"

SELECT
    name,
    COUNT(1) se,
    SUM(value) / 1024 kb,
    MAX(value) / 1024 ma,
    MIN(value) / 1024 mi
FROM
    v$sesstat s,
    v$statname n
WHERE
    name LIKE '%session%memory%'
    AND s.statistic# = n.statistic#
GROUP BY
    name
/

@_END
