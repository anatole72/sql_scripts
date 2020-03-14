REM
REM Shows invalid objects in the database
REM

PROMPT
PROMPT INVALID OBJECTS
PROMPT

ACCEPT own PROMPT "Object owner like (ENTER for all): "
ACCEPT nam PROMPT "Object name like (ENTER for all): "
ACCEPT typ PROMPT "Object type like (ENTER for all): "

@_BEGIN
@_TITLE "INVALID DATABASE OBJECTS"

COLUMN owner        FORMAT A16 HEADING "Object Owner"
COLUMN object_name  FORMAT A30 HEADING "Object Name"
COLUMN object_type  FORMAT A12 HEADING "Object Type"
COLUMN last_time    FORMAT A18 HEADING "Last Change Time"

SELECT
    owner,
    object_name,
    object_type,
    TO_CHAR(last_ddl_time, 'DD-MON-YY hh:mi:ss') last_time
FROM
    dba_objects
WHERE
    owner LIKE NVL(UPPER('&&own'), '%')
    AND object_name LIKE NVL(UPPER('&&nam'), '%')
    AND object_type LIKE NVL(UPPER('&&typ'), '%')
    AND status = 'INVALID'
ORDER BY
    owner,
    object_type,
    object_name
;

UNDEFINE own nam typ

@_END

