REM 
REM  List columns in tables which are all NULL
REM  Author: Mark Lang, 1998
REM

PROMPT
PROMPT COLUMNS IN TABLES WHICH ARE ALL NULL
PROMPT

ACCEPT own PROMPT "Table owner like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "
ACCEPT cln PROMPT "Column name like (ENTER for all): "
ACCEPT typ PROMPT "Column data type like (ENTER for all): "
PROMPT

@_BEGIN
@_HIDE

SPOOL &SCRIPT
SELECT
    'SELECT '''
    || t.owner
    || '.'
    || t.table_name
    || '.'
    || t.column_name
    || ' IS ALL NULL'''
    || &&CR
    ||
    'FROM SYS.DUAL '
    || &&CR
    ||
    'WHERE NOT EXISTS ('
    || &&CR
    ||
    'SELECT 0 '
    || 'FROM '
    || t.owner
    || '.'
    || t.table_name
    || &&CR
    ||
    'WHERE '
    || t.column_name
    || ' IS NOT NULL'
    ||');'
FROM
    sys.dba_tab_columns t
WHERE
    t.owner LIKE NVL(UPPER('&&own'), '%')
    AND t.table_name LIKE NVL(UPPER('&&nam'), '%')
    AND t.column_name LIKE NVL(UPPER('&&cln'), '%')
    AND t.data_type LIKE NVL(UPPER('&&typ'), '%')
ORDER BY
    owner,
    table_name,
    column_name
;
SPOOL OFF

@_BEGIN

SET HEADING OFF
SET PAGESIZE 0

@&SCRIPT

UNDEFINE own nam cln typ

@_END

