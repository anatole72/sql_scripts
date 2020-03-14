REM 
REM  Show standalone tables (tables not involved into PK-FK
REM  relationships)
REM 
REM  Author: Mark Lang, 1998
REM

PROMPT
PROMPT STANDALONE TABLES 
PROMPT
ACCEPT own PROMPT "Table owner like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "

@_BEGIN
@_TITLE "STANDALONE TABLES"

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
        AND constraint_type = 'R'
    )
    AND NOT EXISTS (
        select 0
        FROM dba_constraints c, dba_constraints r
        WHERE c.owner = t.owner
        AND c.table_name = t.table_name
        AND c.constraint_type in ('P', 'U')
        AND c.owner = r.r_owner
        AND c.constraint_name = r.r_constraint_name
    )
ORDER BY
    owner,
    table_name
;

UNDEFINE own nam
@_END
