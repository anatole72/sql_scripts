REM 
REM  Compile all invalid objects in schemas
REM

PROMPT
PROMPT COMPILE ALL INVALID OBJECTS IN SCHEMAS
PROMPT
ACCEPT user PROMPT "User schema like (ENTER for all): "
PROMPT

@_BEGIN
SET HEADING OFF
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT 
    'ALTER '
    || object_type
    || ' '
    || object_name
    || ' COMPILE;'
    || CHR(10)
    || 'SHOW ERROR'
FROM 
    dba_objects 
WHERE 
    owner LIKE NVL(UPPER('&user'), '%') 
    AND status = 'INVALID'
/
SPOOL OFF

@_CONFIRM "recompile"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF
UNDEFINE user

@_END
