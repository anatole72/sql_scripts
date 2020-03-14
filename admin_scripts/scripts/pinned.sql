REM
REM Query the SGA to determine pinned PL/SQL objects
REM
REM DESCRIPTION
REM   Query the shared_pool area to determine space used by PL/SQL objects
REM   and whether they have been pinned.
REM
REM NOTES
REM   This script can be run at any time to determine what PL/SQL objects
REM   are in the SGA, and the total space consumed.
REM

PROMPT
PROMPT SHARED POOL PL/SQL OBJECTS
PROMPT

ACCEPT pin PROMPT "Show pinned objects only (Y/(N)): "
ACCEPT sys PROMPT "Show SYS objects (Y/(N)): "

@_BEGIN
@_TITLE 'SHARED POOL PL/SQL OBJECTS'

COLUMN type     FORMAT A12
COLUMN object   FORMAT A36
COLUMN loads    FORMAT 99990
COLUMN execs    FORMAT 9999990
COLUMN kept     FORMAT A4
COLUMN space    FORMAT 9,999.9  HEADING "SPACE(K)"
BREAK ON REPORT
COMPUTE SUM LABEL TOTAL OF space ON REPORT

SELECT 
    owner || '.' || name object, 
    type,
    sharable_mem / 1024 space, 
    loads, 
    executions execs, 
    kept
FROM 
    v$db_object_cache
WHERE 
    type IN ('FUNCTION', 'PACKAGE', 'PACKAGE BODY', 'PROCEDURE')
    AND owner <> DECODE(UPPER('&&sys'), 'Y', ' ', 'SYS')
    AND kept LIKE DECODE(UPPER('&&pin'), 'Y', 'YES', '' , '%', '%')
ORDER BY 
    owner, 
    name
/

UNDEFINE pin sys
@_END
