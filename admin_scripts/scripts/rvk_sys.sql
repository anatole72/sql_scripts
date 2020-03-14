REM 
REM  Revokes select on SYS tables from a user
REM  Author:  Mark Lang, 1998
REM

PROMPT
PROMPT REVOKE SELECT ON SYS TABLES FROM USERS (WITH GRANT OPTION)
PROMPT

ACCEPT o PROMPT "Object name like (ENTER for all): "
DEFINE obj = "NVL(UPPER('&&o'), '%')"

ACCEPT u PROMPT "Grantee name like (ENTER for PUBLIC): "
DEFINE usr = "NVL(UPPER('&&u'), 'PUBLIC')"

PROMPT

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
  'REVOKE '
  || o.privilege
  || ' ON '
  || o.owner
  || '.'
  || o.table_name
  || ' FROM '
  || o.grantee
  || ';'
FROM
    sys.dba_tab_privs o
WHERE
    o.owner = 'SYS'
    AND o.table_name LIKE &&obj
    AND o.grantee <> 'PUBLIC'
    AND o.grantee LIKE &&usr
;
SPOOL OFF

@_CONFIRM "revoke"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE o obj u usr

@_END
