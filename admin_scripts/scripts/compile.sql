REM 
REM  Recompile invalid database objects
REM  Author: Mark Lang, 1998
REM 

@_BEGIN

SET HEADING OFF
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

PROMPT
PROMPT RECOMPILE INVALID DATABASE OBJECTS
PROMPT

PROMPT Allowable object types:
PROMPT
SELECT DISTINCT object_type FROM dba_objects;
PROMPT
ACCEPT typ PROMPT "Object type like (ENTER for all): "
ACCEPT own PROMPT "Object owner like (ENTER for all): "
ACCEPT nam PROMPT "Object name like (ENTER for all): "
PROMPT

REM Creating of script which will get run later
REM to recompile objects.

SPOOL &SCRIPT
SELECT
    'ALTER ' ||
    o.object_type || ' ' ||
    o.owner || '.' || o.object_name ||
    ' COMPILE;'
FROM
    dba_objects o
WHERE
    o.owner LIKE NVL(UPPER('&&own'), '%')
    AND (USER = 'SYS' OR o.owner <> 'SYS')
    AND o.object_name LIKE NVL(UPPER('&&nam'), '%')
    AND o.object_type LIKE NVL(UPPER('&&typ'), '%')
    AND o.object_type <> 'PACKAGE BODY'
    AND status = 'INVALID'
UNION ALL
SELECT
    'ALTER PACKAGE ' || ' ' ||
    o.owner || '.' || o.object_name ||
    ' COMPILE BODY;'
FROM
    dba_objects o
WHERE
    o.owner LIKE NVL(UPPER('&&own'), '%')
    AND (USER = 'SYS' OR o.owner <> 'SYS')
    AND o.object_name LIKE NVL(UPPER('&&nam'), '%')
    AND o.object_type = 'PACKAGE BODY'
    AND status = 'INVALID'
    AND EXISTS (
        SELECT 0
        FROM dba_objects 
        WHERE owner = o.owner
        AND object_name = o.object_name
        AND object_type = 'PACKAGE'
        AND status = 'VALID'
    )
;

SPOOL OFF

@_CONFIRM "recompile"
@_BEGIN

SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE own nam typ

@_END







