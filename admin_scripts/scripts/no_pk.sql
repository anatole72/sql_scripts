REM 
REM Show tables with no primary key
REM

PROMPT
PROMPT TABLES WITH NO PRIMARY KEY 
PROMPT
ACCEPT own PROMPT "Table owner like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "

@_BEGIN
@_TITLE "TABLES WITH NO PRIMARY KEYS"

BREAK ON owner SKIP 1

SELECT
    owner,
    table_name
FROM
    dba_tables t
WHERE
    owner LIKE NVL(UPPER('&&own'), '%')
    AND table_name LIKE NVL(UPPER('&&nam'), '%')
    AND NOT EXISTS (
        SELECT 0
        FROM dba_constraints c
        WHERE owner = t.owner
        AND table_name = t.table_name
        AND constraint_type = 'P'
    )
ORDER BY
    owner,
    table_name
;

@_END
