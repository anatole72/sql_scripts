REM
REM  Monitor multi-threaded server activity
REM  Author: Mark Lang, 1998
REM

PROMPT
PROMPT MONITOR MULTI-THREADED SERVER ACTIVITY
PROMPT
ACCEPT a PROMPT "Mode ((M)TS, (D)ispatcher, (S)erver, (Q)ueue, (C)ircuit or ENTER for all): "
DEFINE arg  ="NVL(UPPER('&&a'), '%')"

@_BEGIN
@_TITLE "MULTI-THREADED SERVER ACTIVITY"

COLUMN name         FORMAT A5
COLUMN network      FORMAT A20 WRAP
COLUMN status       FORMAT A12
COLUMN accept       FORMAT A3
COLUMN messages     FORMAT 999,990
COLUMN kbytes       FORMAT 999,990
COLUMN breaks       FORMAT 990 HEADING "BRKS"
COLUMN requests     FORMAT 999,990
COLUMN owner        FORMAT 990
COLUMN created      FORMAT 990
COLUMN idle         FORMAT 999,999,990
COLUMN busy         FORMAT 999,990
COLUMN listener     FORMAT 990
COLUMN load         FORMAT 0.999

COLUMN username     FORMAT A12
COLUMN dispatcher   FORMAT A5
COLUMN server       FORMAT A5
COLUMN waiter       FORMAT A5

SELECT *
FROM v$mts
WHERE 'M' LIKE &&arg
;

SELECT
    name,
    status,
    accept,
    messages,
    bytes / 1024 kbytes,
    breaks,
    idle,
    busy,
    busy / (idle + busy) load
FROM v$dispatcher
WHERE 'D' LIKE &&arg
;

SELECT
    name,
    status,
    messages,
    bytes / 1024 kbytes,
    breaks,
    requests,
    idle,
    busy,
    busy / (idle + busy) load
FROM v$shared_server
WHERE 'S' LIKE &&arg
;

SELECT *
FROM v$queue
WHERE 'Q' LIKE &&arg
;

SELECT
    u.username,
    d.name dispatcher,
    s.name server,
    w.name waiter,
    c.bytes/1024 kbytes,
    c.breaks,
    c.status,
    c.queue
FROM
    v$circuit c,
    v$session u,
    v$dispatcher d,
    v$shared_server s,
    v$shared_server w
WHERE
    'C' LIKE &&arg
    AND c.saddr = u.saddr
    AND c.dispatcher = d.paddr
    AND c.server = s.paddr(+)
    AND c.waiter = w.paddr(+)
ORDER BY
    u.username
;

UNDEFINE a arg

@_END

