REM 
REM  Show errors on stored objects
rem  Author: Mark Lang, 1998
REM

PROMPT SHOW ERRORS ON STORED OBJECTS
PROMPT
ACCEPT own PROMPT "Object owner like (ENTER for all): "
ACCEPT nam PROMPT "Object name like (ENTER for all): "

@_BEGIN 
SET HEADING OFF

COLUMN obj      FORMAT A19 HEADING "Program Unit"
COLUMN linepos  FORMAT A8  HEADING "Line/Pos"
COLUMN text     FORMAT A50 HEADING "Description" WORD
BREAK ON obj SKIP 1

SET HEADING ON
SELECT
    e.owner || '.' || e.name obj,
    TO_CHAR(e.line) || '/' || TO_CHAR(e.position) linepos,
    e.text
FROM
    all_errors e
WHERE
    e.owner LIKE NVL(UPPER('&&own'), '%')
    AND e.name LIKE NVL(UPPER('&&nam'), '%')
ORDER BY
    e.owner,
    e.name,
    e.sequence
;
SET HEADING OFF

SELECT
    'Object does not exist.'
FROM
    dual
WHERE NOT EXISTS (
    SELECT * FROM all_objects
    WHERE owner LIKE NVL(UPPER('&&own'), '%')
    AND object_name LIKE NVL(UPPER('&&nam'), '%')
)
;

SELECT
    'No errors.'
FROM
    dual
WHERE EXISTS (
    SELECT * FROM all_objects
    WHERE owner LIKE NVL(UPPER('&&own'), '%')
    AND object_name LIKE NVL(UPPER('&&nam'), '%')
) AND NOT EXISTS (
    SELECT * FROM all_errors
    WHERE owner LIKE NVL(UPPER('&&own'), '%')
    AND name LIKE NVL(UPPER('&&nam'), '%')
)
;

UNDEFINE own nam
@_END

