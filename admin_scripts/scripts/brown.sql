REM
REM  Index statistics report
REM

PROMPT
PROMPT INDEX STATISTICS REPORT
PROMPT

COLUMN del_lf_rows_len      FORMAT 999,999,999 	HEADING 'Deleted Bytes'
COLUMN lf_rows_len          FORMAT 999,999,999 	HEADING 'Filled Bytes'
COLUMN browning             FORMAT 990.90 		HEADING 'Percent|Browned'
COLUMN height               FORMAT 999999 		HEADING 'Height' 
COLUMN blocks               FORMAT 999999 		HEADING 'Blocks' 
COLUMN distinct_keys        FORMAT 999999999 	HEADING 'Distinct|Keys'
COLUMN most_repeated_key    FORMAT 999999999 	HEADING 'Most|Repeated|Key'
COLUMN used_space           FORMAT 999999999 	HEADING 'Used|Space' 
COLUMN rows_per_key         FORMAT 999999 		HEADING 'Rows|Per|Key'

DEFINE cr = 'CHR(10)'
ACCEPT owner PROMPT 'Index owner: '
PROMPT

@_BEGIN
@_HIDE
SPOOL &SCRIPT

SELECT 
    'CREATE TABLE temp$index_stat AS SELECT * FROM index_stats; ' || &&cr ||
    'TRUNCATE TABLE temp$index_stat;'  
FROM DUAL;

SELECT	
    'ANALYZE INDEX '
    || owner || '.' || index_name
    || ' VALIDATE STRUCTURE;' || &&cr ||
    'INSERT INTO temp$index_stat SELECT * FROM index_stats;' || &&cr ||
    'COMMIT;'
FROM
    dba_indexes
WHERE
    owner = UPPER('&owner')
;
SPOOL OFF

@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

@_BEGIN
@_WTITLE "&&owner''s Index Statistics Report"
SELECT 
    name "Name",
    del_lf_rows_len,
    lf_rows_len,
    (del_lf_rows_len / DECODE((lf_rows_len + del_lf_rows_len),
        0, 1, 
        lf_rows_len + del_lf_rows_len)
    ) * 100 browning,
    height, 
    blocks, 
    distinct_keys, 
    most_repeated_key,
    used_space, 
    rows_per_key
FROM 
    temp$index_stat
WHERE 
    rows_per_key > 0
;

@_HIDE
DROP TABLE temp$index_stat;
@_SET
@_END

