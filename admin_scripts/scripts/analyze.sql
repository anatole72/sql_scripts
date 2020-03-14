REM
REM  Creates and runs script which will analyze tables
REM  and clusters for a user using COMPUTE, ESTIMATE or DELETE 
REM  STATISTICS.
REM

PROMPT
PROMPT ANALYZING TABLES AND CLUSTERS
PROMPT

ACCEPT user PROMPT "User name like (ENTER for all): "
ACCEPT obj  PROMPT "Table or cluster name like (ENTER for all): "
ACCEPT type PROMPT "Statistics action ((C)ompute, (E)stimate or (D)elete): "
PROMPT

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

REM Creating of script which will get run later
REM to analyze tables and clusters.

SPOOL &SCRIPT
SELECT
    'ANALYZE TABLE ' ||
    owner || '.' ||        
    table_name || ' ' || 
    DECODE(UPPER('&type'), 
        'C', 'COMPUTE',
        'E', 'ESTIMATE',
        'D', 'DELETE') ||
    ' STATISTICS;'
FROM 
    dba_tables
WHERE
    owner LIKE NVL(UPPER('&user'), '%')
    AND owner NOT IN ('SYS', 'SYSTEM')
    AND table_name LIKE NVL(UPPER('&&obj'), '%')
ORDER BY 
    owner,
    table_name 
/            
SELECT
    'ANALYZE CLUSTER ' ||
    owner || '.' ||        
    cluster_name || ' ' ||
    DECODE(UPPER('&type'), 
        'C', 'COMPUTE',
        'E', 'ESTIMATE',
        'D', 'DELETE') ||
    ' STATISTICS;'
FROM 
    dba_clusters
WHERE 
    owner LIKE NVL(UPPER('&user'), '%')
    AND owner NOT IN ('SYS', 'SYSTEM')
    AND cluster_name LIKE NVL(UPPER('&&obj'), '%')
ORDER BY 
    owner,
    cluster_name
/
SPOOL OFF

@_CONFIRM "analyze"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE user type obj

@_END
