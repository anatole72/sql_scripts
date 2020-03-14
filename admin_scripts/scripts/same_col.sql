REM
REM  Determine use of common column names/types across tables
REM  Author:  Mark Lang, 1998
REM

PROMPT
PROMPT USING OF COMMON COLUMN NAMES/TYPES ACROSS TABLES
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
@_TITLE "COMMON COLUMNS ACROSS TABLES"

COLUMN column_name      FORMAT A30  HEADING "Column Name"
COLUMN data_type        FORMAT A12  HEADING "Type"
COLUMN data_length      FORMAT 9999 HEADING "Length"
COLUMN data_precision   FORMAT 99   HEADING "Prec"
COLUMN data_scale       FORMAT 99   HEADING "Scale"
COLUMN cnt              FORMAT 999  HEADING "Count"

SELECT
    column_name,
    data_type,
    data_length,
    data_precision,
    data_scale,
    COUNT(*) cnt
FROM
    dba_tab_columns
WHERE
    owner LIKE &&own
    AND table_name LIKE &&nam
    AND column_name LIKE &&clm
    AND data_type LIKE &&typ
GROUP BY
    column_name,
    data_type,
    data_length,
    data_precision,
    data_scale
;

UNDEFINE ow own
UNDEFINE na nam
UNDEFINE co clm
UNDEFINE ty typ

@_END

