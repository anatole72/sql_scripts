REM
REM  Shows analyzed statistics for all tables
REM

PROMPT
PROMPT ANALYZED STATISTICS FOR TABLES
PROMPT

ACCEPT own PROMPT "Table owner like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "

REM
REM Calculate database block size
REM
SET HEADING OFF
SET TERMOUT OFF
SET PAGESIZE 0
COLUMN value NOPRINT NEW_VALUE blk_size
SELECT value 
FROM v$parameter
WHERE name = 'db_block_size';

@_BEGIN
@_WTITLE "Table Statistics Report"

COLUMN owner            FORMAT A26            HEADING "Table Owner"
COLUMN table_name       FORMAT A26            HEADING "Table Name"
COLUMN num_rows         FORMAT 999,999,999    HEADING "Rows"
COLUMN blocks           FORMAT 999,999        HEADING "Used|Blocks" 
COLUMN empty_blocks     FORMAT 999,999        HEADING "Empty|Blocks" 
COLUMN empty_pct                              HEADING "%Empty|Blocks"
COLUMN space_full       FORMAT 999.99         HEADING "% Space" 
COLUMN chain_cnt        FORMAT 999,999        HEADING "Chained|Rows"
COLUMN chain_pct                              HEADING "Chain|%"
COLUMN avg_row_len      FORMAT 99,999,999,999 HEADING "Avg Length|(Bytes)"

BREAK ON owner SKIP 1 

SELECT 
    owner, 
    table_name, 
    num_rows, 
    blocks,
    empty_blocks,
    LTRIM(DECODE(blocks, NULL, '', 0, TO_CHAR(0, '990.0'),
        TO_CHAR(empty_blocks / (blocks + empty_blocks) * 100, '990.0'))) empty_pct,
    100 * ((num_rows * avg_row_len) / 
        ((GREATEST(blocks, 1) + empty_blocks) * &blk_size)) space_full,
    chain_cnt,
    LTRIM(DECODE(num_rows, null, '', 0, TO_CHAR(0, '990.0'),
        TO_CHAR(chain_cnt / num_rows * 100, '990.0'))) chain_pct,
    avg_row_len
FROM
    dba_tables
WHERE 
    owner NOT IN ('SYS', 'SYSTEM')
    AND owner LIKE NVL(UPPER('&&own'), '%')
    AND table_name LIKE NVL(UPPER('&&nam'), '%')
    AND num_rows IS NOT NULL
ORDER BY 
    owner, 
    table_name
;

UNDEFINE blk_size own nam
@_END
