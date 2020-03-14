REM
REM  The script lists the foreign keys in a database.
REM
REM  Author: Mark Gurry
REM

PROMPT
PROMPT PRIMARY KEY - FOREIGN KEY RELATIONSHIPS
PROMPT
ACCEPT own PROMPT "Table owner like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "

@_BEGIN
@_TITLE 'Foreign Key Listing'

COLUMN pk HEADING "Primary Key" FORMAT A37
COLUMN fk HEADING "Foreign Key" FORMAT A38
BREAK ON fk SKIP 1

SELECT
    a.owner || '.' || a.table_name || '(' || c.column_name || ')' fk, 
    '->' "->",
    b.owner || '.' || b.table_name || '(' || d.column_name || ')' pk
FROM
    dba_constraints a,
    dba_constraints b,
    dba_cons_columns c,
    dba_cons_columns d
WHERE
    a.r_constraint_name = b.constraint_name
    AND a.constraint_type = 'R'
    AND b.constraint_type = 'P'
    AND a.r_owner = b.owner
    AND a.constraint_name = c.constraint_name
    AND b.constraint_name = d.constraint_name
    AND a.owner = c.owner
    AND a.table_name = c.table_name
    AND b.owner = d.owner
    AND b.table_name = d.table_name
    AND a.owner LIKE NVL(UPPER('&&own'), '%')
    AND a.table_name LIKE NVL(UPPER('&&nam'), '%')    
ORDER BY
    a.owner,
    a.table_name,
    c.column_name
;
@_END

