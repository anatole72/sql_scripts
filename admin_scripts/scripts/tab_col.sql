REM 
REM  List table column definitions
REM

PROMPT
PROMPT TABLE COLUMN DEFINITIONS
PROMPT

ACCEPT ow PROMPT "Table owner like (ENTER for all): "
DEFINE own = "DECODE('&ow', NULL, '%', UPPER('&ow'))"

ACCEPT na PROMPT "Table name like (ENTER for all): "
DEFINE nam = "DECODE('&na', NULL, '%', UPPER('&na'))"

ACCEPT co PROMPT "Column name like (ENTER for all): "
DEFINE clm = "DECODE('&co', NULL, '%', UPPER('&co'))"

ACCEPT ty PROMPT "Column type like (ENTER for all): "
DEFINE typ = "DECODE('&ty', NULL, '%', UPPER('&ty'))"

@_BEGIN
@_WTITLE "TABLE COLUMN DEFINITIONS"

COLUMN tname            FORMAT A40  HEADING "TABLE NAME"
COLUMN column_id        FORMAT 999  HEADING "COL#"
COLUMN column_name      FORMAT A30  HEADING "COLUMN NAME"
COLUMN dtype            FORMAT A14  HEADING "DATATYPE"
COLUMN nulls            FORMAT A3   HEADING "NULL"
COLUMN default_length   FORMAT 90   HEADING "LEN"
COLUMN data_default     FORMAT A31  HEADING "DEFAULT"
BREAK ON tname SKIP 1

SELECT
    owner || '.' || table_name tname,
    column_id,
    column_name,
    data_type || DECODE(DECODE(data_type, 'FLOAT', 'NUMBER', data_type),
        'DATE', '',
        'NUMBER', DECODE(data_precision, NULL, '', '(' || TO_CHAR(data_precision)
            || DECODE(data_scale, NULL, '', 0, '', ',' || TO_CHAR(data_scale)) || ')'),
        DECODE(data_length, NULL, '', 0, '', '('
            || TO_CHAR(data_length) || ')')) dtype,
    DECODE(nullable, 'Y', 'YES', 'NO ') nulls,
    default_length,
    data_default
FROM
    dba_tab_columns
WHERE
    owner LIKE &&own
    AND table_name LIKE &&nam
    AND column_name LIKE &&clm
    AND data_type LIKE &&typ
ORDER BY
    owner,
    table_name,
    column_id
;

UNDEFINE ow own
UNDEFINE na nam
UNDEFINE co clm
UNDEFINE ty typ

@_END

