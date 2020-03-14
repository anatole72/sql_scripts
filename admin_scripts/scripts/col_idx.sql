REM
REM  List indexes on table columns
REM

PROMPT
PROMPT INDEXES ON TABLE COLUMNS
PROMPT

ACCEPT owner PROMPT 'Table owner: '
ACCEPT name PROMPT 'Table name: '

@_BEGIN
@_TITLE "INDEXES ON &owner..&name"

COLUMN i_name           HEADING "Index Name"    FORMAT A40
COLUMN uniq             HEADING "N/U"
COLUMN uniq                                     FORMAT A3
COLUMN column_position  HEADING "Pos"           FORMAT 99
COLUMN column_name      HEADING "Column Name"

BREAK ON i_name SKIP 1 NODUP ON uniq NODUP

SELECT 
    i.owner || '.' || i.index_name i_name, 
    SUBSTR(i.uniqueness, 1, 1) uniq,
    ic.column_position, 
    ic.column_name
FROM   
    dba_indexes i, 
    dba_ind_columns ic
WHERE  
    i.table_owner = UPPER('&owner')
    AND i.table_name = UPPER('&name')
    AND i.table_owner = ic.table_owner
    AND i.table_name = ic.table_name
    AND i.index_name = ic.index_name
ORDER BY 
    1, 3
;

UNDEFINE owner name

@_END
