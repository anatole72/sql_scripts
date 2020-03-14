REM
REM  Resolve public synonyms for objects in a schema
REM 
REM  This useful script will maintain PUBLIC SYNONYMS for objects
REM  in a schema:
REM  - If existing synonym exists which points to something 
REM    different the drop existing
REM  - If synonym does not exist then create
REM  - If existing synonym points to non-existant object then drop
REM
REM  Does not create public synonyms for synonyms
REM  Currently OWNER cannot be a wildcard
REM 
REM  Author: Mark Lang, 1998
REM


PROMPT
PROMPT RESOLVE PUBLIC SYNONYMS
PROMPT

ACCEPT own  PROMPT "Object owner: "
ACCEPT nam  PROMPT "Object name like (ENTER for all): "
PROMPT

@_BEGIN
SET HEADING OFF
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
    DECODE(s.synonym_name,
        NULL, '',
        '/* was '
        || s.table_owner
        || '.'
        || s.table_name
        || DECODE(s.db_link, NULL, '', '@' || s.db_link)
        || ' */'
        || CHR(10)
        || 'DROP PUBLIC SYNONYM '
        || object_name
        || ';'
        || CHR(10)
    )
    || 'CREATE PUBLIC SYNONYM '
    || object_name
    || CHR(10)
    || '  FOR '
    || UPPER('&&own')
    || '.'
    || object_name
    || ';'
FROM
    dba_objects o,
    dba_synonyms s
WHERE
    (o.owner = UPPER('&&own'))
    AND (o.object_name LIKE NVL(UPPER('&&nam'), '%'))
    AND (o.object_name = s.synonym_name(+))
    AND (o.object_type IN (
        'TABLE',
        'VIEW',
        'SEQUENCE',
        'PACKAGE',
        'PROCEDURE',
        'FUNCTION',
        'SNAPSHOT'
    ))
    AND (
        s.owner IS NULL
        OR (s.owner = 'PUBLIC'
            AND (
                s.table_owner <> UPPER('&&own')
                OR s.table_name <> o.object_name
                OR s.db_link IS NOT NULL
            )
            AND (s.table_owner NOT IN ('SYS', 'SYSTEM'))
        )
    )
ORDER BY
    o.object_name
;

REM  Drop all other public synonyms which reference objects in user's
REM  account which no longer exist.

SELECT
    'DROP PUBLIC SYNONYM '
    || synonym_name
    || ';'
FROM
    dba_synonyms s
WHERE
    s.owner = 'PUBLIC'
    AND s.table_name <> 'SYS'
    AND s.table_owner LIKE UPPER('&&own')
    AND s.table_name LIKE NVL(UPPER('&&nam'), '%')
    AND s.db_link IS NULL
    AND NOT EXISTS (
        SELECT 0
        FROM dba_objects
        WHERE owner = s.table_owner
        AND object_name = s.table_name
    )
ORDER BY
    s.synonym_name
;
SPOOL OFF

@_CONFIRM "execute"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE own nam

@_END
