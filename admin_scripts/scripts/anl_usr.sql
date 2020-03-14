REM
REM Creates and runs script which will analyze tables
REM and clusters in specified database schemas.
REM
REM If the table size is greater than 10 Mb in size, statistics 
REM are estimated.
REM

PROMPT
PROMPT ANALYZE ALL TABLES AND CLUSTERS IN SPECIFIED SCHEMAS
PROMPT
ACCEPT sch PROMPT "User schema like (ENTER for all): "
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
    owner || '.' || table_name || ' ' ||
    DECODE(SIGN(10485760 - initial_extent), 1, 'COMPUTE STATISTICS;',
        'ESTIMATE STATISTICS;') 
FROM   
    sys.dba_tables
WHERE  
    owner NOT IN ('SYS', 'SYSTEM')
    AND owner LIKE NVL(UPPER('&&sch'), '%')
ORDER BY
    owner, 
    table_name
/
SELECT 
    'ANALYZE CLUSTER ' ||
    owner || '.' || cluster_name || ' ' ||
    DECODE(SIGN(10485760 - initial_extent), 1, 'COMPUTE STATISTICS;',
        'ESTIMATE STATISTICS;') 
FROM   
    sys.dba_clusters
WHERE  
    owner NOT IN ('SYS', 'SYSTEM')
    AND owner LIKE NVL(UPPER('&&sch'), '%')
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

UNDEFINE sch

@_END
