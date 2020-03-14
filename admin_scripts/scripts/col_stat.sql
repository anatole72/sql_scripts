REM
REM  Analyzed statistics for table(s) columns
REM  

PROMPT
PROMPT ANALYZED STATISTICS FOR TABLE(S) COLUMNS
PROMPT

ACCEPT own PROMPT "Table owner like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "
ACCEPT clm PROMPT "Column name like (ENTER for all): "
ACCEPT typ PROMPT "Column type like (ENTER for all): "

@_BEGIN
@_TITLE "Table column statistics"

COLUMN tname        FORMAT A25      HEADING "TABLE"
COLUMN column_name  FORMAT A23      HEADING "COLUMN"
COLUMN num_distinct FORMAT 999,990  HEADING "DISTINCT"
COLUMN density      FORMAT 0.999    HEADING "DENSIT"
COLUMN num_nulls    FORMAT 999,990  HEADING "NULLS"
COLUMN num_buckets  FORMAT 990      HEADING "BUCK" 
BREAK ON tname SKIP 1

SELECT
    owner || '.' || table_name tname,
    column_name,
    num_distinct,
    density,
    num_nulls,		-- 7.3
    num_buckets	    -- 7.3
FROM
    dba_tab_columns c
WHERE
    owner LIKE NVL(UPPER('&&own'), '%')
    AND table_name LIKE NVL(UPPER('&&nam'), '%')
    AND column_name LIKE NVL(UPPER('&&clm'), '%')
    AND data_type LIKE NVL(UPPER('&&typ'), '%')
    AND num_distinct IS NOT NULL
ORDER BY
    owner,
    table_name,
    column_name
;

UNDEFINE own nam clm typ

@_END

