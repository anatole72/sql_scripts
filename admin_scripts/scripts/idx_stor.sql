@_BEGIN
@_WTITLE "INDEX STORAGE PARAMETERS"

COLUMN c1  FORMAT A18   HEADING "Tablespace"
COLUMN c2  FORMAT A35   HEADING "Owner"
COLUMN c3  FORMAT A25   HEADING "Index"
COLUMN c4               HEADING "Size|(Kb)"
COLUMN c5  FORMAT 999   HEADING "Exts"
COLUMN c6  FORMAT 999   HEADING "Max|Ext"
COLUMN c7               HEADING "Init|(Kb)"
COLUMN c8               HEADING "Next|(Kb)"
COLUMN c9  FORMAT 99    HEADING "%Inc"
COLUMN c10 FORMAT 99    HEADING "%Free"

BREAK ON c1 SKIP 1 

SELECT
    di.tablespace_name c1,
    di.owner || '.' || di.table_name c2,
    di.index_name c3,
    ds.bytes / 1024 c4,
    ds.extents c5,
    di.max_extents c6,
    di.initial_extent / 1024 c7,
    di.next_extent / 1024 c8,
    di.pct_increase c9,
    di.pct_free c10
FROM
    sys.dba_segments ds,
    sys.dba_indexes di
WHERE
    ds.tablespace_name = di.tablespace_name
    AND ds.owner = di.owner
    AND ds.segment_name = di.index_name 
ORDER BY
    1, 2
;
@_END
