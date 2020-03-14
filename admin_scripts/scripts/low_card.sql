REM 
REM  List indexes on low cardinality columns.
REM 
REM  Requires ANALYZE..STATISTICS on tables and indexes.
REM  <pct> = distinct_keys / num_rows * 100
REM 

PROMPT
PROMPT INDEXES ON LOW CARDINALITY COLUMNS
PROMPT
PROMPT Tables and indexes must be analyzed for computation!
@_CONFIRM "continue"

PROMPT
ACCEPT own PROMPT "Table owner like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "
ACCEPT pct PROMPT "Max distinct percent (ENTER for 100): " NUMBER

@_BEGIN
@_TITLE "INDEXES ON LOW CARDINALITY COLUMNS"

COLUMN tname            FORMAT A32          HEADING "Table Name"
COLUMN iname            FORMAT A23          HEADING "Index Name"
COLUMN num_rows         FORMAT 9,999,990    HEADING "Rows"
COLUMN distinct_keys    FORMAT 9,999        HEADING "Keys"
COLUMN pct              FORMAT 999          HEADING "%"

SELECT
    i.table_owner || '.' || i.table_name tname,
    i.index_name iname,
    t.num_rows,
    distinct_keys,
    DECODE(t.num_rows, 0, 0, (i.distinct_keys / t.num_rows * 100)) pct
FROM
    dba_indexes i,
    dba_tables t
WHERE
    i.table_owner LIKE NVL(UPPER('&&own'), '%')
    AND i.table_name LIKE NVL(UPPER('&&nam'), '%')
    AND i.table_owner = t.owner
    AND i.table_name = t.table_name
    AND DECODE(t.num_rows, 0, 0, (i.distinct_keys / t.num_rows * 100)) > 0
    AND DECODE(t.num_rows, 0, 0, (i.distinct_keys / t.num_rows * 100))
        <= DECODE(&&pct, 0, 100, &&pct)
ORDER BY
    1, 2
;

UNDEFINE own nam pct

@_END

