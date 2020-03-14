REM 
REM  Drop triggers on a table
REM

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

PROMPT
PROMPT DROP TRIGGERS ON A TABLE
PROMPT

ACCEPT own PROMPT "Table owner like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "
PROMPT

SPOOL &SCRIPT
SELECT
    'DROP TRIGGER '
    || owner
    || '.'
    || trigger_name
    || ';'
FROM
    dba_triggers
WHERE
    table_owner <> 'SYS'
    AND table_owner LIKE NVL(UPPER('&&own'), '%')
    AND table_name LIKE NVL(UPPER('&&nam'), '%')
;
SPOOL OFF

@_CONFIRM "drop"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE own nam 

@_END

