REM 
REM  Mass change password for group of users
REM  By Mark Lang, 1998
REM 

PROMPT
PROMPT CHANGE PASSWORD FOR GROUP OF USERS
PROMPT

ACCEPT u PROMPT "User name like (ENTER for all): "
DEFINE usr = "NVL(UPPER('&&u'), '%')"

ACCEPT r PROMPT "Role name like (ENTER for all): "
DEFINE rol = "NVL(UPPER('&&r'), '%')"

ACCEPT t PROMPT "Change password for ([U]ser [R]ole or ENTER for both): "
DEFINE typ = "NVL(UPPER('&&t'), 'UR')"

ACCEPT p PROMPT "Role password required? ((Y)es, (N)o, ENTER for both): "
DEFINE pas = "UPPER('&&p%')"

ACCEPT passwd CHAR PROMPT "New password: " HIDE
ACCEPT verpas CHAR PROMPT "Reenter to verify: " HIDE

PROMPT
DEFINE sysroles = "'CONNECT', 'RESOURCE', 'DBA', 'IMP_FULL_DATABASE', 'EXP_FULL_DATABASE'"
DEFINE sysusers = "'SYS', 'SYSTEM'"

@_BEGIN
SET HEADING OFF
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
    'ALTER USER '
    || username
    || ' IDENTIFIED BY '
    || '&&passwd;'
FROM
    sys.dba_users u
WHERE
    INSTR(&&typ, 'U') > 0
    AND username LIKE &&usr
    AND username NOT IN (&&sysusers)
    AND (
        &&rol = '%'
        OR EXISTS (
            SELECT 0
            FROM sys.dba_role_privs
            WHERE grantee = u.username
            AND granted_role LIKE &&rol
        )
    )
    AND UPPER('&&passwd') = UPPER('&&verpas')
ORDER BY
    u.username
;

SELECT
    'ALTER ROLE '
    || role
    || ' IDENTIFIED BY '
    || '&&passwd;'
FROM
    sys.dba_roles u
WHERE
    INSTR(&&typ, 'R') > 0
    AND role LIKE &&usr
    AND role NOT IN (&&sysroles)
    AND (
        &&rol = '%'
        OR EXISTS (
            SELECT 0
            FROM sys.dba_role_privs
            WHERE grantee = u.role
            AND granted_role LIKE &&rol
        )
    )
    AND password_required LIKE &&pas
    AND UPPER('&&passwd') = UPPER('&&verpas')
ORDER BY
    role
;

SPOOL OFF

@_CONFIRM "alter"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE u usr
UNDEFINE r rol
UNDEFINE t typ
UNDEFINE p pas
UNDEFINE passwd verpas
UNDEFINE sysusers sysroles

@_END

