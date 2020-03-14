REM
REM  Report on table and view column definitions
REM  MRA 9/18/96
REM

PROMPT
PROMPT TABLE, CLUSTER AND VIEW COLUMN DEFINITIONS
PROMPT

ACCEPT owner PROMPT "Table owner like (ENTER for all): "
ACCEPT table PROMPT "Table name like (ENTER for all): "
ACCEPT colum PROMPT "Column name like (ENTER for all): "

@_BEGIN
@_TITLE "Table Columns Report"

COLUMN table_name 	FORMAT A30 	HEADING "Table or View Name"
COLUMN column_name 	FORMAT A23 	HEADING "Column Name"
COLUMN data_type 	FORMAT A10 	HEADING "Data Type"
COLUMN data_length 			    HEADING "Length"
COLUMN nullable 	FORMAT A3 	HEADING "Nul"
BREAK ON table_name SKIP 1

SELECT 
    table_name || ' (' ||object_type || ')' table_name, 
    column_name,
    data_type,
    data_length,
    DECODE(nullable, 'N', 'NO', 'YES') nullable
FROM 
    dba_tab_columns a, dba_objects b 
WHERE
    a.owner LIKE NVL(UPPER('&&owner'), '%') 
    AND a.owner = b.owner 
    AND a.table_name LIKE NVL(UPPER('&&table'), '%') 
    AND a.table_name = b.object_name 
    AND object_type IN ('TABLE', 'VIEW', 'CLUSTER')
    AND column_name LIKE NVL(UPPER('&&colum'), '%') 
ORDER BY 
    table_name, 
    column_id
/
@_END
