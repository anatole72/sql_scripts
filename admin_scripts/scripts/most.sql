REM
REM This script shows the objects being stored in the shared pool
REM in descending order of a given criteria
REM

PROMPT
PROMPT MOST CONSUMED PL/SQL OBJECTS IN SHARED POOL
PROMPT
ACCEPT ord PROMPT "Criteria ((M)emory, (L)oads, (E)xecutions): "

@_BEGIN
@_TITLE "MOST CONSUMED PL/SQL OBJECTS IN SHARED POOL"

COLUMN name     FORMAT A48
COLUMN memory   FORMAT 999,999,999
COLUMN loads    FORMAT 999,999
COLUMN execs    FORMAT 999,999

SELECT
    owner || '.' || name || ' (' || type || ')' name, 
    sharable_mem memory,
    loads,
    executions execs
FROM 
    v$db_object_cache
WHERE 
    type IN ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
ORDER BY 
    DECODE(UPPER('&&ord'),
        'M', sharable_mem,
        'L', loads,
        'E', executions,
        sharable_mem
    ) DESC
;

UNDEFINE ord

@_END
