REM
REM  Expanded Index Report
REM

PROMPT
PROMPT EXPANDED INDEX REPORT
PROMPT

ACCEPT iown PROMPT "Index owner like (ENTER for all): "
ACCEPT inam PROMPT "Index name like (ENTER for all): "
ACCEPT town PROMPT "Table owner like (ENTER for all): "
ACCEPT tnam PROMPT "Table name like (ENTER for all): "
ACCEPT ts   PROMPT "Tablespace name like (ENTER for all): "

@_BEGIN
@_WTITLE 'Expanded Index Report'

COLUMN index_name 	    FORMAT A40 	HEADING 'Index Name'
COLUMN table_name 	    FORMAT A37 	HEADING 'Table Name'
COLUMN column_name 	    FORMAT A25 	HEADING 'Column Name'
COLUMN table_type 	    FORMAT A10 	HEADING 'Table|Type'
COLUMN uniqueness 	    FORMAT A1 	HEADING 'U|N'
COLUMN tablespace_name	FORMAT A13 	HEADING 'Tablespace'

BREAK -
    ON index_name -
    ON table_name -
    ON table_type -
    ON uniqueness -
    ON tablespace_name

SELECT
    a.owner || '.' ||
    a.index_name index_name,     
    a.table_owner || '.' ||
    a.table_name table_name,     
    b.column_name,
    a.table_type,     
    DECODE (a.uniqueness, 
        'UNIQUE', 'U',
        'NONUNIQUE','N'
    ) uniqueness,     
    a.tablespace_name
FROM 
    dba_indexes a,
    dba_ind_columns b
WHERE 
    owner LIKE NVL(UPPER('&iown'), '%')
    AND a.index_name LIKE NVL(UPPER('&inam'), '%')
    AND a.table_owner LIKE NVL(UPPER('&town'), '%')
    AND a.table_name LIKE NVL(UPPER('&tnam'), '%')
    AND a.tablespace_name LIKE NVL(UPPER('&ts'), '%')
    AND a.owner = b.index_owner(+) 
    AND a.index_name = b.index_name(+)
ORDER BY
    1, 2, 3
;

@_END
