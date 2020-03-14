REM 
REM  Display user PGA memory usage
REM  Author: Mark Lang, 1998
REM

PROMPT
PROMPT USER PGA MEMORY USAGE
PROMPT
ACCEPT usr PROMPT "User name like (ENTER for all): "
ACCEPT min PROMPT "Min PGA size (ENTER for 0): " NUMBER

@_BEGIN
@_TITLE "USER PGA MEMORY USAGE"

COLUMN username     FORMAT A20
COLUMN pga          FORMAT 999,999,990  HEADING "PGA"
COLUMN pmx          FORMAT 999,999,990  HEADING "PGA MAX"
COLUMN pct          FORMAT 999.99       HEADING "% MAX"

SELECT
    s.username,
    s.osuser,
    tpga.value pga, 
    tpmx.value pmx, 
    tpga.value / tpmx.value * 100 pct
FROM 
    v$session  s, 
    v$sesstat  tpga,
    v$statname npga,
    v$sesstat  tpmx,
    v$statname npmx
WHERE
    s.username LIKE NVL(UPPER('&&usr'), '%')
    AND tpga.sid = s.sid
    AND tpga.statistic# = npga.statistic#
    AND npga.name = 'session pga memory'
    AND tpmx.sid = s.sid
    AND tpmx.statistic# = npmx.statistic#
    AND npmx.name = 'session pga memory max'
    AND tpga.value >= &&min
ORDER BY
    DECODE(&&min, 0, s.username, LPAD(tpga.value, 15))
;

UNDEFINE usr min

@_END
