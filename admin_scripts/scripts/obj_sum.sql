REM 
REM  Display summary of database objects by type
REM 

PROMPT
PROMPT DATABASE OBJECTS SUMMARY BY TYPE
PROMPT
ACCEPT own PROMPT "Object owner like (ENTER for all): "
ACCEPT nam PROMPT "Object name like (ENTER for all): "
ACCEPT typ PROMPT "Object type like (ENTER for all): "

@_BEGIN
@_TITLE "OBJECTS SUMMARY BY TYPE"

COLUMN owner       FORMAT A30    HEADING "Owner"
COLUMN object_type FORMAT A15    HEADING "Object Type"
COLUMN cnt         FORMAT 999990 HEADING "Total"
COLUMN valid       FORMAT 999990 HEADING "Valid"
COLUMN invalid     FORMAT 999990 HEADING "Invalid"
BREAK ON owner SKIP 1

SELECT
    owner,
    object_type,
    COUNT(*) cnt,
    SUM(DECODE(status, 'VALID', 1, 0)) valid,
    SUM(DECODE(status, 'INVALID', 1, 0)) invalid
FROM
    dba_objects
WHERE
    owner LIKE NVL(UPPER('&&own'), '%')
    AND object_name LIKE NVL(UPPER('&&nam'), '%')
    AND object_type LIKE NVL(UPPER('&&typ'), '%')
GROUP BY
    owner,
    object_type
;

UNDEFINE own nam typ

@_END
