REM
REM Queries statistics collected by ANALYZE for a user
REM
REM NOTES: Output of the script is not formatted completely.
REM

PROMPT
PROMPT STATISTICS COLLECTED BY ANALYZE FOR A USER
PROMPT

ACCEPT user PROMPT "User name: "

@_BEGIN

@_TITLE "&&user''s Table statistics"
SET NUMWIDTH 9
COLUMN table_name FORMAT A19

SELECT	
    table_name,
    num_rows,
    blocks,
    empty_blocks empty,
    avg_space,
    chain_cnt,
    avg_row_len avg_row
FROM 	
    dba_tables
WHERE
    owner = UPPER('&user')
    AND num_rows IS NOT NULL
ORDER BY 
    table_name
/

@_TITLE "&&user''s Indexes statistics"
SET NUMWIDTH 9
COLUMN index_name FORMAT A28
COLUMN blevel FORMAT 99999
COLUMN avg_1 FORMAT 99999
COLUMN avg_2 FORMAT 99999

SELECT
    table_name || '.' || index_name index_name,
    blevel,
    leaf_blocks leaf_blks,
    distinct_keys dist_keys,
    avg_leaf_blocks_per_key avg_1,
    avg_data_blocks_per_key avg_2,
    clustering_factor c_factor
    /*status*/
FROM 
    dba_indexes
WHERE
    owner = UPPER('&user')
    AND blevel IS NOT NULL
ORDER BY 
    table_name, index_name
/

@_TITLE 'Statistics about indexes for foreign tables'
SET NUMWIDTH 9
COLUMN index_name FORMAT A28

SELECT
    table_owner || '.' || table_name || '.' || index_name index_name,
    blevel,
    leaf_blocks             leaf_blks,
    distinct_keys           dist_keys,
    avg_leaf_blocks_per_key avg_1,
    avg_data_blocks_per_key avg_2,
    clustering_factor       c_factor
    /*status*/
FROM 
    dba_indexes
WHERE 
    owner = UPPER('&user')
    AND table_owner != UPPER('&user')
    AND blevel IS NOT NULL
ORDER BY 
    table_owner, table_name, index_name
/

UNDEFINE user
@_END

