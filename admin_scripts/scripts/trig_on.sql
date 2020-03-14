REM 
REM  Enable triggers
REM 
REM  Author: Mark Lang, 1998
REM 

PROMPT
PROMPT ENABLE TRIGGERS
PROMPT

ACCEPT own PROMPT "Table owner like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "
PROMPT

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
    'ALTER TABLE '
    || t.owner
    || '.'
    || t.table_name
    || ' ENABLE ALL TRIGGERS;'
FROM
    dba_tables t
WHERE
    t.owner LIKE NVL(UPPER('&&own'), '%')
    AND t.table_name LIKE NVL(UPPER('&&nam'), '%')
    AND EXISTS (
        SELECT 1
        FROM dba_triggers g
        WHERE g.table_owner = t.owner
        AND g.table_name = t.table_name
        AND g.status = 'DISABLED'
    )
ORDER BY
    t.owner,
    t.table_name
;
SPOOL OFF

@_CONFIRM "enable triggers"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE own nam 

@_END

