REM 
REM  Create an ORACLE user account like another account
REM  Author: Mark Lang, 1998
REM 

PROMPT
PROMPT CREATE AN USER ACCOUNT LIKE ANOTHER ACCOUNT
PROMPT

ACCEPT new PROMPT "New user: "
ACCEPT old PROMPT "Like user: "
PROMPT

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
    'CREATE USER &&new IDENTIFIED BY &&new' || &&CR ||
    'DEFAULT TABLESPACE ' || default_tablespace || &&CR ||
    'TEMPORARY TABLESPACE ' || temporary_tablespace || ';'
FROM
    sys.dba_users u
WHERE
    username = UPPER('&&old')
    AND NOT EXISTS (
        SELECT 0
        FROM sys.dba_users
        WHERE username = UPPER('&&new')
    )
;

SELECT
    'GRANT ' || privilege || ' TO &&new;'
FROM sys.dba_sys_privs p
WHERE grantee = UPPER('&&old')
;
SELECT
    'GRANT ' || granted_role || ' TO &&new;'
FROM sys.dba_role_privs p
WHERE grantee = UPPER('&&old')
;
SELECT
    'GRANT ' || privilege || ' ON '
        || owner || '.' || table_name || ' TO &&new;'
FROM sys.dba_tab_privs p
WHERE grantee = UPPER('&&old')
;
SELECT
    'GRANT ' || privilege || ' ON ' || owner || '.' || table_name ||
    '(' || column_name || ') TO &&new;'
FROM sys.dba_col_privs p
WHERE grantee = UPPER('&&old')
;
SPOOL OFF

@_CONFIRM "create"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE new old 

@_END




