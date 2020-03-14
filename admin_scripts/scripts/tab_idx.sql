REM
REM Tables and their indexes
REM

PROMPT
PROMPT TABLES AND THEIR INDEXES
PROMPT

ACCEPT town PROMPT "Table owner like (ENTER for all): "
ACCEPT tnam PROMPT "Table name like (ENTER for all): "
ACCEPT iown PROMPT "Index owner like (ENTER for all): "
ACCEPT inam PROMPT "Index name like (ENTER for all): "

@_BEGIN
@_TITLE "TABLE INDEXES"

COLUMN table_name FORMAT A35 HEADING Table
COLUMN index_name FORMAT A35 HEADING Index

BREAK ON table_name  

SELECT  DISTINCT
    table_owner || '.' || table_name table_name,
    owner || '.' || index_name index_name,
    SUBSTR(status, 1, 3) "Sta",
    SUBSTR(uniqueness, 1, 3) "Uni"
FROM
    sys.dba_indexes
WHERE
    table_owner LIKE NVL(UPPER('&town'), '%') 
    AND table_name LIKE NVL(UPPER('&tnam'), '%') 
    AND owner LIKE NVL(UPPER('&iown'), '%')
    AND owner NOT IN ('SYS', 'SYSTEM')
    AND index_name LIKE NVL(UPPER('&inam'), '%') 
    AND table_type = 'TABLE'
ORDER BY
    table_name,
    index_name
/

@_END
