REM 
REM  Drop database objects. USE WITH CAUTION!
REM 
REM  Author:  Mark Lang, 1998
REM 

@_BEGIN
SET HEADING OFF
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

PROMPT
PROMPT DROP DATABASE OBJECTS
PROMPT

ACCEPT own PROMPT "Object owner like (ENTER for all): "
ACCEPT nam PROMPT "Object name like (ENTER for all): "
PROMPT
PROMPT Allowed object types:
PROMPT
    SELECT DISTINCT object_type
    FROM dba_objects
    WHERE
        owner LIKE NVL(UPPER('&&own'), '%')
        AND object_type NOT IN ('PACKAGE BODY')
    ORDER BY object_type;
PROMPT
ACCEPT typ PROMPT "Object type like (ENTER for all): "
PROMPT

SPOOL &SCRIPT
SELECT
    'DROP ' || o.object_type || ' '
    || o.owner || '.' || o.object_name
    || DECODE(o.object_type,
        'TABLE', ' CASCADE CONSTRAINTS',
        'CLUSTER', ' INCLUDING TABLES CASCADE CONSTRAINTS'
        )
    || ';'
FROM
    dba_objects o
WHERE
    o.owner <> 'SYS'
    AND o.owner LIKE NVL(UPPER('&&own'), '%')
    AND o.object_name LIKE NVL(UPPER('&&nam'), '%')
    AND o.object_type LIKE NVL(UPPER('&&typ'), '%')
    AND o.object_type NOT IN ('PACKAGE BODY')
ORDER BY
    o.owner,
    o.object_name
;
SPOOL OFF

@_CONFIRM "drop"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE own nam

@_END

