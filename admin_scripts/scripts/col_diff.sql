REM
REM  This script lists columns that have the same name but
REM  different characteristics. They may cause problems
REM  when tables are joined on the columns or unexpected 
REM  results are returned. 
REM
REM  Author:  Mark Gurry
REM

PROMPT
PROMPT COLUMNS WITH THE SAME NAME AND DIFFERENT CHARACTERISTICS
PROMPT

ACCEPT own PROMPT "Table owner like (ENTER for all): " 
ACCEPT nam PROMPT "Table name like (ENTER for all): "
ACCEPT clm PROMPT "Column name like (ENTER for all): "

@_BEGIN
@_TITLE 'Columns with Inconsistent Data Lengths'

COLUMN owner HEADING "Owner" FORMAT A17
COLUMN column_name HEADING "Column Name" FORMAT A20
COLUMN characteristics HEADING "What Table and Type" FORMAT A40

BREAK ON owner ON column_name SKIP 1;
  
SELECT 
    owner, 
    column_name, 
    table_name || ' ' || 
    data_type || '(' ||
    DECODE(data_type, 
        'NUMBER', data_precision, 
        data_length) || ')' characteristics
FROM 
    dba_tab_columns
WHERE 
    (column_name, owner) IN (
        SELECT 
            column_name, 
            owner
        FROM 
            dba_tab_columns
        GROUP BY 
            column_name, 
            owner
        HAVING 
            MIN(DECODE(data_type, 'NUMBER', data_precision, data_length)) < 
            MAX(DECODE(data_type, 'NUMBER', data_precision, data_length)) 
     )
     AND owner NOT IN ('SYS', 'SYSTEM')
     AND owner LIKE NVL(UPPER('&&own'), '%')
     AND table_name LIKE NVL(UPPER('&&nam'), '%')
     AND column_name LIKE NVL(UPPER('&&clm'), '%')
/
UNDEFINE own nam clm
@_END
