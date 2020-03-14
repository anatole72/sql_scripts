REM 
REM  Display updatable columns in views
REM  

PROMPT
PROMPT UPDATABLE COLUMNS IN VIEWS
PROMPT
ACCEPT own PROMPT "View owner like (ENTER for all): "
ACCEPT nam PROMPT "View name like (ENTER for all): "
ACCEPT cln PROMPT "Column name like (ENTER for all): "
ACCEPT upd PROMPT "Show updatable ((Y)es, (N)o, ENTER for all): "

@_BEGIN
@_TITLE "UPDATABLE COLUMNS"

COLUMN tname        FORMAT A41 HEADING "Table"
COLUMN column_name  FORMAT A30 HEADING "Column"
COLUMN updatable    FORMAT A6  HEADING "Update"
BREAK ON tname SKIP 1

SELECT
    u.owner || '.' || u.table_name tname,
    u.column_name,
    u.updatable
FROM
    dba_updatable_columns u,
    dba_views v
WHERE
    u.owner LIKE NVL(UPPER('&&own'), '%')
    AND u.table_name LIKE NVL(UPPER('&&nam'), '%')
    AND u.column_name LIKE NVL(UPPER('&&cln'), '%')
    AND u.updatable LIKE UPPER('&&upd%')
    AND u.owner = v.owner
    AND u.table_name = v.view_name
ORDER BY
    u.owner,
    u.table_name,
    u.column_name
;

UNDEFINE own nam cln upd

@_END

