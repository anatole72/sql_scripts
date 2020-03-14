REM 
REM  Information about clusters (physical aspects)
REM

PROMPT
PROMPT C L U S T E R S
PROMPT

ACCEPT own PROMPT "Cluster owner like (ENTER for all): "
ACCEPT nam PROMPT "Cluster name like (ENTER for all): "
ACCEPT typ PROMPT "Cluster type like ((I)ndex, (H)ash, ENTER for all): "
ACCEPT tsp PROMPT "Tablespace name like (ENTER for all): "

@_BEGIN
@_TITLE "Clusters Report"

COLUMN clusters	 		    FORMAT A25      HEADING "Cluster"
COLUMN tablespace_name      FORMAT A10      HEADING "Tablespace"
COLUMN avg_blocks_per_key   FORMAT 999999   HEADING "Blocks|per Key"
COLUMN cluster_type         FORMAT A8       HEADING "Type"
COLUMN function 		    FORMAT 999999   HEADING "Function"
COLUMN hashkeys 		    FORMAT 99999    HEADING "# of Keys" 

SELECT 
    owner || '.' || cluster_name clusters,
    tablespace_name,
    avg_blocks_per_key, 
    cluster_type, 
    function,
    hashkeys
FROM 
    dba_clusters
WHERE
    owner LIKE NVL(UPPER('&&own'), '%')
    AND cluster_name LIKE NVL(UPPER('&&nam'), '%')
    AND tablespace_name LIKE NVL(UPPER('&&tsp'), '%')
    AND cluster_type LIKE UPPER('&&typ%')
ORDER BY 
    owner,
    cluster_name
/

UNDEFINE own nam tsp typ
@_END
