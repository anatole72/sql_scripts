REM 
REM  Set user tablespace defaults (by user name or role)
REM  Author: Mark Lang, 1998
REM 

@_BEGIN
SET PAGESIZE 0

PROMPT
PROMPT SET USER DEFAULT TABLESPACES BY USER NAME OR ROLE
PROMPT

ACCEPT usr PROMPT "User name like (ENTER for all): "
ACCEPT rol PROMPT "User role like (ENTER for all): "

PROMPT
PROMPT Available tablespaces:
SELECT tablespace_name FROM dba_tablespaces ORDER BY tablespace_name;
PROMPT

ACCEPT dts PROMPT "Default tablespace (ENTER if none): "
ACCEPT tts PROMPT "Temporary tablespace (ENTER if none): "
PROMPT

SPOOL &SCRIPT
SELECT
  'ALTER USER ' || u.username ||
  DECODE('&&dts', NULL, '', &&CR || 'DEFAULT TABLESPACE ' || '&&dts') ||
  DECODE('&&tts', NULL, '', &&CR || 'TEMPORARY TABLESPACE ' || '&&tts') ||
  ';'
FROM
    sys.dba_users u
WHERE
    u.username LIKE NVL(UPPER('&&usr'), '%')
    AND u.username <> 'SYS'
    AND (
        '&&rol' IS NULL
        OR NVL(UPPER('&&rol'), '%') = '%'
        OR EXISTS (
            SELECT NULL
            FROM sys.dba_role_privs
            WHERE grantee = u.username
            AND granted_role LIKE NVL(UPPER('&&rol'), '%')
        )
    )
    AND (
            (
            '&&dts' IS NOT NULL
            AND u.default_tablespace <> NVL(UPPER('&&dts'), '%')
            )
        OR
            (
            '&&tts' IS NOT NULL
            AND u.temporary_tablespace <> NVL(UPPER('&&tts'), '%')
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

UNDEFINE usr rol dts tts

@_END

