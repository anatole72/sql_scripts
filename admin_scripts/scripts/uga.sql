REM 
REM  Display user UGA memory usage
REM 

PROMPT
PROMPT USER UGA MEMORY USAGE
PROMPT

ACCEPT u PROMPT "User name like (ENTER for all): "
DEFINE usr = "NVL(UPPER('&&u'), '%')"
ACCEPT min PROMPT "Min UGA memory (ENTER for 0): " NUMBER

@_BEGIN
@_TITLE "USER UGA MEMORY USAGE"

COLUMN username FORMAT A20
COLUMN uga      FORMAT 999,999,990  HEADING "UGA"
COLUMN umx      FORMAT 999,999,990  HEADING "UGA MAX"
COLUMN pct      FORMAT 999.99       HEADING "% MAX"

SELECT
    s.username,
    tuga.value uga,
    tumx.value umx,
    tuga.value / tumx.value * 100 pct
FROM
    v$session s,
    v$sesstat tuga,
    v$statname nuga,
    v$sesstat tumx,
    v$statname numx
WHERE
    s.username LIKE &&usr
    AND tuga.sid = s.sid
    AND tuga.statistic# = nuga.statistic#
    AND nuga.name = 'session uga memory'
    AND tumx.sid = s.sid
    AND tumx.statistic# = numx.statistic#
    AND numx.name = 'session uga memory max'
    AND tuga.value >= &&min
ORDER BY
    DECODE(&&min, 0, s.username, LPAD(tuga.value, 15))
;

UNDEFINE u usr min

@_END
