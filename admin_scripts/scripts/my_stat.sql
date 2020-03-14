REM
REM Reports various statistics about the current session 
REM

@_BEGIN
@_TITLE "CURRENT SESSION STATISTICS"

SELECT
    n.name,
    s.value
FROM
    v$statname n,
    v$sesstat s
WHERE
    n.statistic# = s.statistic#
    AND value > 0
    AND s.sid = (
        SELECT a.sid
        FROM v$process p, v$session a
        WHERE p.addr = a.paddr
        AND a.terminal = USERENV('terminal')
    )
ORDER BY
    n.class,
    n.name
/
@_END


