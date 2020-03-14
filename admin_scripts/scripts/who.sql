REM
REM  Who are working?
REM

PROMPT
PROMPT WHO ARE WORKING?
PROMPT

ACCEPT os_user      PROMPT "OS user like (ENTER for all): "
ACCEPT oracle_user  PROMPT "Oracle user like (ENTER for all): "

@_BEGIN
@_TITLE "WHO ARE WORKING?"

SELECT
    NVL(s.osuser, s.type) os_user,
    s.username oracle_user,
    s.sid oracle_sid,
    s.process f_ground,
    p.spid b_ground
FROM
    v$session s,
    v$process p
WHERE
    NVL(UPPER(s.osuser), '?') LIKE NVL(UPPER('&os_user'), '%')
    AND NVL(UPPER(s.username), '?') LIKE NVL(UPPER('&oracle_user'), '%')
    AND s.paddr = p.addr
ORDER BY
    s.sid
/

UNDEFINE os_user oracle_user

@_END
