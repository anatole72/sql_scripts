REM
REM  Report on "bad" objects in the shared pool
REM

PROMPT
PROMPT BAD OBJECTS IN THE SHARED POOL
PROMPT
ACCEPT own PROMPT "Owner name like (ENTER for all): "

@_BEGIN
@_TITLE 'SHARED POOL BAD OBJECTS'

COLUMN owner        FORMAT A10      HEADING Schema
COLUMN name         FORMAT A29      HEADING Object|Name
COLUMN namespace                    HEADING Name|Space
COLUMN type                         HEADING Object|Type
COLUMN sharable_mem FORMAT 999999   HEADING Shared|Memory

BREAK ON owner SKIP 1 ON namespace

SELECT  
    owner, 
    namespace,
    type,
    name,
    sharable_mem
FROM 
    v$db_object_cache
WHERE 
    type IN ('NOT LOADED', 'NON-EXISTENT')
    AND owner LIKE NVL(UPPER('&&own'), '%')
ORDER BY 
    owner,
    namespace,
    type,
    name
;

UNDEFINE own

@_END


