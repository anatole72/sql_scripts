REM 
REM  Display database objects of some type
REM 

PROMPT
PROMPT DATABASE OBJECTS
PROMPT
ACCEPT own PROMPT "Object owner like (ENTER for all): "
ACCEPT nam PROMPT "Object name like (ENTER for all): "
ACCEPT typ PROMPT "Object type like (ENTER for all): "
ACCEPT sta PROMPT "Object status like (ENTER for all): "
ACCEPT ord PROMPT "Order by ((N)ame, (T)ype, (S)tatus): "

@_BEGIN
@_WTITLE "DATABASE OBJECTS"

COLUMN owner        FORMAT A30  
COLUMN object_name  FORMAT A30  HEADING "OBJECT NAME"
COLUMN object_type  FORMAT A12  HEADING "TYPE"
COLUMN created                  HEADING "CREATED"
COLUMN last_ddl_time            HEADING "LAST DDL"
COLUMN status                   HEADING "STATUS"

SELECT
    owner,
    object_name,
    object_type,
    created,
    last_ddl_time,
    status
FROM
    dba_objects
WHERE
    owner LIKE NVL(UPPER('&&own'), '%')
    AND object_name LIKE NVL(UPPER('&&nam'), '%')
    AND object_type LIKE NVL(UPPER('&&typ'), '%')
    AND status LIKE NVL(UPPER('&&sta'), '%')
ORDER BY
    DECODE(UPPER('&&ord'),
        'N', RPAD(owner, 30) || object_name,
        'T', object_type,
        'S', status,
        RPAD(owner, 30) || object_name)
;

UNDEFINE own nam sta typ ord

@_END
