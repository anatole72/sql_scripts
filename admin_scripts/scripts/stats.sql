REM
REM  Shows session/system statistics
REM  Author: Mark Lang, 1998
REM

PROMPT
PROMPT SESSION/SYSTEM STATISTICS
PROMPT
PROMPT Possible modes:
PROMPT
PROMPT 1. Enter username or username pattern to see user (session) statistics.
PROMPT 2. Enter 0 for system statistics.
PROMPT 3. Enter SUM, MIN, MAX, AVG, STD or VAR to aggregate statistics for all users.
PROMPT 4. Enter DIS to see all distinct values of statistics.
PROMPT 5. Enter ? for current session statistics.
PROMPT
ACCEPT u PROMPT "Mode: "
DEFINE usr = "UPPER('&&u')"
ACCEPT s PROMPT "Statistic name like (ENTER for all): "
DEFINE stn = "NVL(UPPER('&&s'), '%')"
ACCEPT m PROMPT "Statistic min value (ENTER for 0): "
DEFINE min = "DECODE('&&m', '%', 0, NULL, 0, TO_NUMBER('&&m'))"

@_BEGIN
@_TITLE "S T A T I S T I C S"

COLUMN stat#    FORMAT 9990           HEADING "STAT#"
COLUMN sid      FORMAT 9990           HEADING "SID"
COLUMN name     FORMAT A15            HEADING "NAME"
COLUMN statname FORMAT A35            HEADING "STATISTIC" WORD
COLUMN value    FORMAT 99,999,999,990 HEADING "VALUE"

REM
REM  User statistics
REM

SELECT
    s.statistic# stat#,
    s.sid sid,
    u.username name,
    n.name statname,
    s.value value
FROM
    v$sesstat s,
    v$statname n,
    v$session u
WHERE
    &&usr NOT IN ('0', 'SUM', 'MIN', 'MAX', 'AVG', 'STD', 'VAR')
    AND (
        u.username LIKE &&usr
        OR (&&usr = '?' AND u.audsid = USERENV('sessionid'))
    )
    AND s.statistic# = n.statistic#
    AND s.sid = u.sid
    AND UPPER(n.name) LIKE &&stn
    AND value >= &&min
ORDER BY
    DECODE(&&min, 0, u.username, 'X'),
    n.name,
    s.value
;

REM
REM  System statistics
REM

SELECT
    s.statistic# stat#,
    0 sid,
    d.name,
    s.name statname,
    s.value value
FROM
    v$sysstat s,
    v$database d
WHERE
    &&usr = '0'
    AND UPPER(s.name) LIKE &&stn
ORDER BY
    s.name
;

REM
REM  Current statistics
REM

SELECT
    MAX(s.statistic#) stat#,
    0 sid,
    MAX(d.name)
        || ' '
        || &&usr
        || ' of '
        || LTRIM(TO_CHAR(COUNT(*))) name,
    MAX(n.name) statname,
    DECODE(&&usr,
        'MIN', MIN(s.value),
        'MAX', MAX(s.value),
        'AVG', AVG(s.value),
        'STD', STDDEV(s.value),
        'VAR', VARIANCE(s.value),
        SUM(s.value)
    ) value
FROM
    v$sesstat s,
    v$statname n,
    v$database d
WHERE
    &&usr IN ('SUM', 'MIN', 'MAX', 'AVG', 'STD', 'VAR')
    AND s.statistic# = n.statistic#
    AND upper(n.name) LIKE &&stn
GROUP BY
    s.statistic#,
    n.name
ORDER BY
    n.name
;

REM
REM  Distinct Values
REM

SELECT
    MAX(s.statistic#) stat#,
    0 sid,
    MAX(d.name)
        || ' DISTINCT '
        || LTRIM(TO_CHAR(COUNT(*))) name,
    n.name statname,
    s.value value
FROM
    v$sesstat s,
    v$statname n,
    v$session u,
    v$database d
WHERE
    &&usr IN ('DIS')
    AND s.statistic# = n.statistic#
    AND s.sid = u.sid
    AND UPPER(n.name) LIKE &&stn
GROUP BY
    n.name,
    s.value
;

UNDEFINE u usr s stn m min

@_END
