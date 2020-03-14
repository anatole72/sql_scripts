REM
REM  Report of direct role grants to users and  direct role grants to roles.
REM
REM  By Joseph C. Trezzo
REM

PROMPT
PROMPT DIRECT ROLE GRANTS
PROMPT

ACCEPT usr PROMPT "Grantee name like (ENTER for all): "
ACCEPT rol PROMPT "Granted role like (ENTER for all): "

@_BEGIN
@_TITLE "DIRECT ROLE GRANTS"

COLUMN username      FORMAT A30  HEADING "Grantee"
COLUMN what_granted  FORMAT A48  HEADING "Granted Roles"
BREAK ON username SKIP 1

SELECT 
    u.username,
    p.granted_role || 
        DECODE(p.admin_option, 
            'YES', ' (With Admin Option)', 
            null) what_granted
FROM
    sys.dba_users u,
    sys.dba_role_privs p
WHERE
    u.username = p.grantee
    AND u.username LIKE NVL(UPPER('&&usr'), '%')
    AND p.granted_role LIKE NVL(UPPER('&&rol'), '%')
UNION ALL
SELECT 
    grantee,
    granted_role || 
        DECODE(admin_option, 
            'YES', ' (With Admin Option)', 
            NULL) what_granted
FROM
    sys.dba_role_privs
WHERE
    NOT EXISTS (
        SELECT 'x' FROM dba_users
        WHERE username = grantee
        )
    AND grantee LIKE NVL(UPPER('&&usr'), '%')
    AND granted_role LIKE NVL(UPPER('&&rol'), '%')
ORDER BY 
    1
/

UNDEFINE usr rol

@_END
