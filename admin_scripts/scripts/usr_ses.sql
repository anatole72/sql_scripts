rem 
rem  Show users session information
rem  Author:  Mark Lang, 1998
rem

PROMPT
PROMPT USER SESSIONS
PROMPT
ACCEPT usr PROMPT "User name like (ENTER for all): "
ACCEPT sts PROMPT "Status like (ENTER for all): "

@_BEGIN
@_TITLE "S E S S I O N S"

COLUMN username FORMAT A12
COLUMN sid      FORMAT A8
COLUMN serv_c   FORMAT A1 HEADING "S"
COLUMN disp     FORMAT A4
COLUMN circ_c   FORMAT A1 HEADING "C"
COLUMN pid      FORMAT A9 
COLUMN program  FORMAT A32 WRAP
COLUMN status	FORMAT A5 HEADING "STAT" TRUNC

SELECT
    s.username,
    s.sid || ',' || s.serial# sid,
    SUBSTR(s.server, 1, 1) serv_c,
    d.name disp,
    SUBSTR(c.status, 1, 1) circ_c,
    s.process pid,
    s.program program,
    s.status
FROM
    v$session s,
    v$circuit c,
    v$dispatcher d
WHERE
    s.username IS NOT NULL
    AND (
        s.username LIKE NVL(UPPER('&&usr'), '%')
        OR s.program LIKE NVL(UPPER('&&usr'), '%')
        OR d.name LIKE NVL(UPPER('&&usr'), '%')
    )
    AND s.saddr = c.saddr(+)
    AND c.dispatcher = d.paddr(+)
    AND s.status LIKE NVL(UPPER('&&sts'), '%')
/*
UNION
SELECT
    s.username,
    s.sid || ',' || s.serial#,
    SUBSTR(s.server, 1, 1) serv_c,
    NULL,
    NULL,
    s.process pid,
    s.program program,
    s.status
FROM
    v$session s
WHERE
    s.username IS NOT NULL
    AND (
        s.username LIKE NVL(UPPER('&&usr'), '%')
        OR s.program LIKE NVL(UPPER('&&usr'), '%')
    )
    AND NOT EXISTS (
        SELECT 0
        FROM v$circuit
        WHERE saddr = s.saddr
    )
*/
ORDER BY
    1, 2
;

UNDEFINE usr sts

@_END
