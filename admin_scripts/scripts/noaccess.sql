REM 
REM  Lists items which have no grants
REM 

PROMPT
PROMPT OBJECTS WHICH HAVE NO GRANTS
PROMPT
ACCEPT own PROMPT "Object owner like (ENTER for all): "
ACCEPT nam PROMPT "Object name like (ENTER for all): "

@_BEGIN
@_TITLE "OBJECTS WITHOUT GRANTS"

COLUMN object_name FORMAT A30
BREAK ON owner SKIP 1

SELECT
    owner,
    object_name,
    object_type
FROM
    sys.dba_objects o
WHERE
    o.owner LIKE NVL(UPPER('&&own'), '%')
    AND o.object_name LIKE NVL(UPPER('&&nam'), '%')
    AND o.object_type NOT IN ('INDEX', 'SYNONYM', 'TRIGGER', 'DATABASE LINK')
    AND NOT EXISTS (
        SELECT *
        FROM sys.dba_tab_privs
        WHERE
            owner = o.owner
            AND table_name = o.object_name
    )
ORDER BY
    owner,
    object_name
;

UNDEFINE own nam

@_END

