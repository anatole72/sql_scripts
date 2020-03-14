REM
REM  This script is designed to run on an ORACLE7.x database.
REM
REM  This script creates a script that recreates the CREATE USER commands 
REM  required to rebuild the database user community. The script includes 
REM  the tablespace quota grants for each user as a set of ALTER USER commands. 
REM  The user’s passwords are initially set to the username so editing is 
REM  suggested if other values are desired.
REM
REM  Only preliminary testing has been accomplished on this script, 
REM  please fully qualify it for your environment before use.
REM
REM  M. Ault TRECOM 3.30.96
REM

PROMPT
PROMPT SCRIPT TO RECREATE USERS
PROMPT
ACCEPT usr PROMPT "User name like (ENTER for all): "

@_BEGIN
DEFINE cr = 'CHR(10)'
SET PAGESIZE 0

SELECT 
    'CREATE USER ' || username || &&cr ||
    '    IDENTIFIED BY ' || username || &&cr ||
    '    DEFAULT TABLESPACE ' || default_tablespace || &&cr ||
    '    TEMPORARY TABLESPACE ' || temporary_tablespace || &&cr ||
    '    PROFILE ' || profile || &&cr ||
    '    QUOTA UNLIMITED ON ' || default_tablespace || ';' || &&cr x
FROM 
    dba_users
WHERE 
    username NOT IN ('SYS', 'SYSTEM')
    AND username LIKE NVL(UPPER('&&usr'), '%')
UNION
SELECT 
    'ALTER USER ' || username || &&cr ||
    '    QUOTA ' || bytes || ' ON ' || tablespace_name || ';' || &&cr x
FROM 
    dba_ts_quotas
WHERE 
    username NOT IN ('SYS', 'SYSTEM')
    AND username LIKE NVL(UPPER('&&usr'), '%')
ORDER BY
    x DESC
/

UNDEFINE usr
@_END
