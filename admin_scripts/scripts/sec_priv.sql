REM
REM  Report of direct system privilege grants to users and 
REM  direct system privilege grants to roles.
REM
REM  By Joseph C. Trezzo, modified by S.S.
REM

PROMPT
PROMPT DIRECT SYSTEM PRIVILEGE GRANTS
PROMPT

ACCEPT grn PROMPT "Grantee name like (ENTER for all): "
ACCEPT pri PROMPT "Granted privilege like (ENTER for all): "

@_BEGIN
@_TITLE "DIRECT SYSTEM PRIVILEGE GRANTS"

COLUMN username      FORMAT A30  HEADING "Grantee"
COLUMN what_granted  FORMAT A40  HEADING "Granted Privilege"
COLUMN admin_option  FORMAT A6   HEADING "Admin|Option"
BREAK ON username SKIP 1

SELECT 
    u.username,
    p.privilege what_granted,
    p.admin_option
FROM
    sys.dba_users u,
    sys.dba_sys_privs p
WHERE
    u.username = p.grantee
    AND p.privilege LIKE NVL(UPPER('&&pri'), '%')
    AND p.grantee LIKE NVL(UPPER('&&grn'), '%')
UNION ALL
SELECT 
    grantee,
    privilege what_granted,
    admin_option
FROM
    sys.dba_sys_privs
WHERE
    NOT EXISTS (
        SELECT 'x' FROM dba_users
        WHERE username = grantee
        )
    AND privilege LIKE NVL(UPPER('&&pri'), '%')
    AND grantee LIKE NVL(UPPER('&&grn'), '%')
ORDER BY 
    1, 2
/

UNDEFINE pri grn
@_END
