REM
REM  Shared pool stored object statistics
REM

@_BEGIN
@_WTITLE "SHARED POOL REPORT"

COLUMN owner        FORMAT A16      HEADING Schema
COLUMN namespace                    HEADING Name|Space
COLUMN type                         HEADING Object|Type
COLUMN name         FORMAT A30      HEADING Object|Name
COLUMN sharable_mem FORMAT 999,999  HEADING Shared|Memory
COLUMN loads                        HEADING Loads
COLUMN executions   FORMAT 999,999  HEADING Executes
COLUMN locks                        HEADING Locks
COLUMN pins                         HEADING Pins
COLUMN kept         FORMAT A4       HEADING Kept
BREAK ON owner SKIP 1 ON namespace ON type SKIP 1 

SELECT  
    owner, 
    namespace,
    type,
    name,
    sharable_mem,
    loads,  
    executions,   
    locks,    
    pins,
    kept
FROM 
    v$db_object_cache
WHERE 
    type NOT IN ('NOT LOADED', 'NON-EXISTENT')
    AND executions > 0
ORDER BY
    owner,
    namespace,
    type,
    name
/
@_END
