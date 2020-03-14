REM 
REM  Drop users by name or by role (ignoring SYS and SYSTEM)
REM  Author:  Mark Lang, 1998
REM 

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

PROMPT
PROMPT D R O P   U S E R S
PROMPT

ACCEPT usr PROMPT "User name like: "
ACCEPT rol PROMPT "Role name like: "
PROMPT

SPOOL &SCRIPT
SELECT
    'DROP USER '
    || u.username
    || ' CASCADE;'
FROM
    sys.dba_users u
WHERE
    u.username NOT IN ('SYS','SYSTEM')
    AND u.username LIKE UPPER('&&usr')
    AND (
        '&&rol' = '%'
        OR EXISTS (
            SELECT 0
            FROM sys.dba_role_privs
            WHERE grantee = u.username
            AND granted_role LIKE UPPER('&&rol')
        )
    )
;
SPOOL OFF

@_CONFIRM "drop user(s)"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE usr rol 

@_END

