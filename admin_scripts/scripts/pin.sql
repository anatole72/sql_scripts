REM
REM  Pin already cached packages in the shared pool
REM

PROMPT
PROMPT PIN CACHED PACKAGES IN SGA
PROMPT

ACCEPT own PROMPT "Owner name like (ENTER for all): "
ACCEPT nam PROMPT "Package name like (ENTER for all): "
PROMPT

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
    'EXEC SYS.DBMS_SHARED_POOL.KEEP('''
    || owner
    || '.'
    || name
    || ''');'
FROM
    v$db_object_cache
where
    OWNER LIKE NVL(UPPER('&&own'), '%')
    AND name LIKE NVL(UPPER('&&nam'), '%')
    AND type = 'PACKAGE'
ORDER BY
    owner,
    name
;
SPOOL OFF

@_CONFIRM "pin"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE own nam

@_END

