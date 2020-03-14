REM
REM  Report on indexes statistics
REM  

PROMPT
PROMPT INDEX STATISTIC REPORT
PROMPT

ACCEPT town PROMPT "Table owner like (ENTER for all): "
ACCEPT tnam PROMPT "Table name like (ENTER for all): "
ACCEPT iown PROMPT "Index owner like (ENTER for all): "
ACCEPT inam PROMPT "Index name like (ENTER for all): "

@_BEGIN
@_WTITLE "Index Statistic Report"

COLUMN tab_name                 FORMAT A40      HEADING "Table Name"                 
COLUMN index_name               FORMAT A27      HEADING "Index Name"
COLUMN status                   FORMAT A7       HEADING "Status"
COLUMN blevel                   FORMAT 99999    HEADING "Tree|Level"
COLUMN leaf_blocks              FORMAT 99999    HEADING "Leaf|Blocks"
COLUMN distinct_keys            FORMAT 9999999  HEADING "# Keys"
COLUMN avg_leaf_blocks_per_key  FORMAT 9999     HEADING "Leaf Blocks|per Key"
COLUMN avg_data_blocks_per_key  FORMAT 9999     HEADING "Data Blocks|per Key"
COLUMN clustering_factor        FORMAT 999999   HEADING "Cluster|Factor"
BREAK ON tab_name

SELECT
    table_owner || '.' || table_name tab_name,
    index_name, 
    status, 
    blevel, 
    leaf_blocks,
    distinct_keys, 
    avg_leaf_blocks_per_key,
    avg_data_blocks_per_key, 
    clustering_factor
FROM 
    dba_indexes
WHERE
    owner LIKE NVL(UPPER('&&iown'), '%') 
    AND index_name LIKE NVL(UPPER('&&inam'), '%')
    AND table_owner LIKE NVL(UPPER('&&town'), '%')
    AND table_name LIKE NVL(UPPER('&&tnam'), '%')
AND 
    distinct_keys > 0
ORDER BY 
    1, 2
;

UNDEFINE iown inam tnam town

@_END
