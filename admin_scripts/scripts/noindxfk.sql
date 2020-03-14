REM
REM  The script lists foreign keys that are missing indexes on
REM  the foreign key columns in the child table. If the index
REM  is not in place, share lock problems may occur on the 
REM  parent table.
REM
REM  Author: Mark Gurry
REM

@_BEGIN
@_WTITLE 'Foreign Keys with Missing Indexes' 

COLUMN owner    FORMAT A30
COLUMN cons     FORMAT A30 HEADING "CONSTRAINT"
COLUMN tab_name FORMAT A30 HEADING "TABLE"
COLUMN col_name FORMAT A30 HEADING "COLUMN"
COLUMN pos      FORMAT 99
BREAK ON owner SKIP 1

SELECT DISTINCT
    acc.owner,
    acc.constraint_name cons,
    acc.table_name tab_name,
    acc.column_name col_name,
    acc.position pos
FROM  
    all_cons_columns acc, 
    all_constraints ac
WHERE  
    ac.constraint_name = acc.constraint_name
    AND ac.constraint_type = 'R'
    AND (acc.owner, acc.table_name, acc.column_name, acc.position) IN (
        SELECT
            acc.owner, 
            acc.table_name, 
            acc.column_name, 
            acc.position 
        FROM   
            all_cons_columns acc, 
            all_constraints ac
        WHERE  
            ac.constraint_name = acc.constraint_name
            AND ac.constraint_type = 'R'
        MINUS
        SELECT 
            table_owner, 
            table_name, 
            column_name, 
            column_position
        FROM 
            all_ind_columns
    )
ORDER BY 
    acc.owner, 
    acc.table_name, 
    acc.column_name, 
    acc.position
;
@_END
