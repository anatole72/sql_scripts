REM 
REM  Drop indexes on the selected tables
REM  Author: Mark Lang, 1998
REM

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

PROMPT
PROMPT DROP INDEXES ON THE SELECTED TABLES
PROMPT

ACCEPT own PROMPT "Table owner like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "
ACCEPT idx PROMPT "Index name like (ENTER for all): "
ACCEPT typ PROMPT "Index type ((U)nique, (N)onunique, ENTER for both): "
PROMPT

SPOOL &SCRIPT
SELECT
    'DROP INDEX '
    || i.owner
    || '.'
    || i.index_name
    || ';'
FROM
    dba_indexes i
WHERE
    i.table_owner LIKE NVL(UPPER('&&own'), '%') 
    AND i.table_name LIKE NVL(UPPER('&&nam'), '%')
    AND i.owner <> 'SYS'
    AND i.index_name LIKE NVL(UPPER('&&idx'), '%')
    AND i.uniqueness LIKE
        DECODE(UPPER('&&typ'),
            'U', 'UNIQUE',
            'N', 'NONUNIQUE',
            '%'
        )
    AND NOT EXISTS (
        SELECT 0
        FROM dba_constraints
        WHERE owner = i.table_owner
        AND index_name = constraint_name
        AND constraint_type IN ('P', 'U')
    )
ORDER BY
    i.table_owner,
    i.table_name,
    i.index_name
;
SPOOL OFF

@_CONFIRM "drop"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE own nam idx typ 

@_END

