REM
REM  Performs "command" on each object
REM 
REM  Notes:
REM  1. USE WITH CAUTION!
REM  2. Executes <command> for each object matched--substitutions to
REM     <command> are made as follows:
REM
REM		{o}	owner
REM		{n}	object_name
REM		{y}	object_type
REM
REM  Author:  Mark Lang, 1998
REM

PROMPT
PROMPT PERFORM "COMMAND" ON EACH OBJECT
PROMPT
PROMPT The "command" must be defined using following substitution parameters:
PROMPT {o} for owner, {n} for object name and {y} for object type. For example:
PROMPT
PROMPT DROP {y} {o}.{n};

@_CONFIRM "continue"

PROMPT
ACCEPT cmd PROMPT "Command: " 
ACCEPT own PROMPT "Object owner like (ENTER for all): "
ACCEPT nam PROMPT "Object name like (ENTER for all): "
ACCEPT typ PROMPT "Object type like (ENTER for all): "
ACCEPT tsp PROMPT "Tablespace name like (ENTER for all): "
ACCEPT rol PROMPT "Role name like (ENTER for all): "
PROMPT

@_BEGIN
SET HEADING OFF
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
    REPLACE(
        REPLACE(
            REPLACE(
                '&&cmd',
                '{o}', o.owner
            ),
            '{n}', o.object_name
        ),
        '{y}', o.object_type
    ) text
FROM
    sys.dba_objects o,
    sys.dba_segments s
WHERE
    o.owner LIKE NVL(UPPER('&&own'), '%')
    AND o.object_name LIKE NVL(UPPER('&&nam'), '%')
    AND o.object_type LIKE NVL(UPPER('&&typ'), '%')
    AND o.object_type not in ('PACKAGE BODY')
    AND o.owner = s.owner
    AND o.object_name = s.segment_name(+)
    AND (
        s.segment_name IS NULL
        OR s.tablespace_name LIKE NVL(UPPER('&&tsp'), '%')
    )
    AND (
        NVL(UPPER('&&rol'), '%') = '%'
        OR EXISTS (
            SELECT *
            FROM sys.dba_tab_privs
            WHERE owner = o.owner
            AND table_name = o.object_name
            AND grantee LIKE NVL(UPPER('&&rol'), '%')
        )
    )
ORDER BY
    o.owner,
    o.object_name
;
SPOOL OFF

@_CONFIRM "execute"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE cmd own nam typ tsp rol

@_END
