REM
REM  ORACLE USER REPORT
REM

PROMPT
PROMPT DATABASE USER REPORT
PROMPT
ACCEPT usr PROMPT "Username like (ENTER for all): "
ACCEPT rol PROMPT "Role like (ENTER for all): "
ACCEPT prf PROMPT "Profile like (ENTER faor all): "

@_BEGIN
@_WTITLE 'DATABASE USER REPORT'

COLUMN username                 FORMAT A24 HEADING User
COLUMN default_tablespace       FORMAT A24 HEADING "Default Tablespace"
COLUMN temporary_tablespace     FORMAT A24 HEADING "Temporary Tablespace"
COLUMN granted_role             FORMAT A22 HEADING Roles
COLUMN default_role             FORMAT A8  HEADING Default?
COLUMN admin_option             FORMAT A6  HEADING Admin?
COLUMN profile                  FORMAT A17 HEADING 'Users Profile'

BREAK -
    ON username SKIP 1 -
    ON default_tablespace -
    ON temporary_tablespace -
    ON profile

SELECT 
    username, 
    default_tablespace, 
    temporary_tablespace, 
    profile,
    granted_role, 
    admin_option, 
    default_role 
FROM 
    sys.dba_users a, 
    sys.dba_role_privs b
WHERE 
    a.username = b.grantee
    AND username LIKE NVL(UPPER('&&usr'), '%')
    AND granted_role LIKE NVL(UPPER('&&rol'), '%')
    AND profile LIKE NVL(UPPER('&&prf'), '%')
ORDER BY 
    username,
    default_tablespace, 
    temporary_tablespace, 
    profile, 
    granted_role
;

UNDEFINE usr rol prf

@_END
