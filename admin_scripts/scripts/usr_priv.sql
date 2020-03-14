REM 
REM  The following script allows to obtain information about which 
REM  privileges are available to a given user, or which users enjoy a
REM  particular privilege.
REM

PROMPT
PROMPT USER PRIVILEGES
PROMPT

ACCEPT un PROMPT "User name like (ENTER for all): "
ACCEPT rn PROMPT "Role name like (ENTER for all): "
ACCEPT pr PROMPT "Privilege like (ENTER for all): "

@_BEGIN
@_TITLE "USER PRIVILEGES"

BREAK ON username SKIP 1 ON rolename SKIP 1

SELECT 
    username, rolename, privilege 
FROM (
    SELECT 
        DECODE(sa1.grantee#, 1, 'PUBLIC', u1.name) username, 
        SUBSTR(u2.name, 1, 20) rolename,
        SUBSTR(spm.name, 1, 27) privilege
    FROM 
        sys.sysauth$ sa1, 
        sys.sysauth$ sa2, 
        sys.user$ u1,
        sys.user$ u2, 
        sys.system_privilege_map spm
    WHERE 
        sa1.grantee# = u1.user#
        AND sa1.privilege# = u2.user#
        AND u2.user# = sa2.grantee#
        AND sa2.privilege# = spm.privilege
    UNION
    SELECT 
        u.name, 
        NULL, 
        SUBSTR(spm.name, 1, 27)
    FROM 
        sys.system_privilege_map spm, 
        sys.sysauth$ sa, 
        sys.user$ u
    WHERE 
        sa.grantee# = u.user#
        AND sa.privilege# = spm.privilege
) 
WHERE
    username LIKE NVL(UPPER('&un'), '%')
    AND rolename LIKE NVL(UPPER('&rn'), '%')
    AND privilege LIKE NVL(UPPER('&pr'), '%') 
/

UNDEFINE un rn pr
@_END


