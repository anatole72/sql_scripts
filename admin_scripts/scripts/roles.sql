REM 
REM  List roles
REM

PROMPT
PROMPT R O L E S
PROMPT

ACCEPT rol PROMPT "Role name like (ENTER for all): "
ACCEPT grt PROMPT "Grantee like (ENTER for all): "

@_BEGIN
@_TITLE "R O L E S"

SELECT
    role,
    password_required
FROM
    sys.dba_roles r
WHERE
    role LIKE NVL(UPPER('&&rol'), '%')
    AND (
        '&&grt' IS NULL
        OR EXISTS (
            SELECT 0
            FROM sys.dba_role_privs
            WHERE grantee = r.role
            AND granted_role LIKE NVL(UPPER('&&grt'), '%')
        )
    ) 
ORDER BY
    role
;

UNDEFINE rol grt

@_END
