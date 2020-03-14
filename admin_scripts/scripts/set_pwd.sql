REM 
REM  Set the standard user password (by user name or role)
REM

PROMPT
PROMPT SET THE STANDARD USER PASSWORD BY USER NAME OR ROLE
PROMPT

ACCEPT usr PROMPT "User name like (ENTER for all): "
ACCEPT rol PROMPT "User role like (ENTER for all): "
PROMPT

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
    'ALTER USER ' 
    || u.username 
    || ' IDENTIFIED BY ' 
    || u.username 
    || ';'
FROM
    sys.dba_users u
WHERE
    u.username LIKE NVL(UPPER('&&usr'), '%')
    AND u.username NOT IN ('SYS', 'SYSTEM')
    AND (
        NVL(UPPER('&&rol'), '%') IN ('*', '%')
        OR EXISTS (
            SELECT NULL
            FROM sys.dba_role_privs
            WHERE grantee = u.username
            AND granted_role LIKE UPPER('&&rol')
        )
    )
ORDER BY
    u.username
;
SPOOL OFF

@_CONFIRM "alter user"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE usr rol 

@_END

