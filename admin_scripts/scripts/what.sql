REM
REM  Current sessions and SQL statements
REM

PROMPT
PROMPT CURRENT SESSIONS AND SQL STATEMENTS
PROMPT

ACCEPT os_user      PROMPT "OS user like (ENTER for all): "
ACCEPT oracle_user  PROMPT "Oracle user like (ENTER for all): "
ACCEPT sid          PROMPT "SID like (ENTER for all): "

@_BEGIN
@_WTITLE "CURRENT SESSIONS AND SQL STATEMENTS"

COLUMN sid      FORMAT 9999
COLUMN username FORMAT A20
COLUMN osuser   FORMAT A12
COLUMN machine  FORMAT A12
COLUMN program  FORMAT A12
COLUMN sql_text FORMAT A45 WORD_WRAP

SELECT /*+ ORDERED */
    s.sid, 
    s.username, 
    s.osuser, 
    NVL(s.machine, '?') machine, 
    NVL(s.program, '?') program,
    s.process f_ground, 
    p.spid b_ground, 
    x.sql_text
FROM
    sys.v_$session s,
    sys.v_$process p, 
    sys.v_$sqlarea x
WHERE
    s.osuser LIKE LOWER(NVL('&os_user', '%'))
    AND s.username LIKE UPPER(NVL('&oracle_user', '%'))
    AND s.sid LIKE NVL('&sid', '%')
    AND s.paddr = p.addr 
    AND s.type != 'BACKGROUND' 
    AND s.sql_address = x.address
    AND s.sql_hash_value = x.hash_value
ORDER BY
    s.sid
/

UNDEFINE os_user oracle_user sid

@_END
