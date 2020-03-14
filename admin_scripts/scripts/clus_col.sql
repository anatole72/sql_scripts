REM
REM  Generate a report on database clusters showing cluster, 
REM  tables, and column data
REM
REM  MRA RevealNet 10/23/95
REM

PROMPT
PROMPT REPORT ON CLUSTERS, THEIR TABLES AND COLUMNS
PROMPT

ACCEPT own PROMPT "Cluster owner like (ENTER for all): "
ACCEPT nam PROMPT "Cluster name like (ENTER for all): "

@_BEGIN
@_WTITLE "CLUSTERS-TABLES-COLUMNS REPORT"


COLUMN owner            FORMAT A23 HEADING "Owner"
COLUMN cluster_name     FORMAT A23 HEADING "Cluster"
COLUMN table_name       FORMAT A27 HEADING "Table"
COLUMN tab_column_name  FORMAT A27 HEADING "Table Column"
COLUMN clu_column_name  FORMAT A27 HEADING "Cluster Column"

BREAK -
    ON owner SKIP 1 -
    ON cluster_name SKIP 1 -
    ON table_name

SELECT 
    a.owner,
    a.cluster_name,
    table_name,
    tab_column_name,
    clu_column_name
FROM 
    dba_clusters a,
    dba_clu_columns b
WHERE
    a.cluster_name = b.cluster_name
    AND a.owner LIKE NVL(UPPER('&&own'), '%')
    AND a.cluster_name LIKE NVL(UPPER('&&nam'), '%')
ORDER BY 
    1, 2, 3, 4
/

UNDEFINE own nam

@_END
