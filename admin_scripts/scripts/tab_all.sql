PROMPT 
PROMPT ALL STATISTICS FOR A TABLE
PROMPT

ACCEPT owner PROMPT 'Table owner: ' 
ACCEPT table_name  PROMPT 'Table name: '

@_BEGIN
@_TITLE "ALL STATISTICS FOR &owner..&table_name"

COLUMN table_name           FORMAT A27          HEADING "Table Name" 
COLUMN num_rows             FORMAT 99,999,990   HEADING "Number|of Rows" 
COLUMN blocks               FORMAT 999,990      HEADING "Blocks" 
COLUMN empty_blocks         FORMAT 999,990      HEADING "Empty|Blocks" 
COLUMN avg_space            FORMAT 9,990        HEADING "Average|Space" 
COLUMN chain_cnt            FORMAT 9990         HEADING "Chain|Count"
COLUMN avg_row_len          FORMAT 9990         HEADING "Average|Row Len"

COLUMN column_name          FORMAT A30          HEADING "Column Name"
COLUMN num_distinct         FORMAT 99,999,990   HEADING "Distinct|Values"
COLUMN density              FORMAT 99990        HEADING "Density"

COLUMN index_name           FORMAT A19          HEADING "Index|Name"
COLUMN uniqueness           FORMAT A4           HEADING "Uniq" TRUNC
COLUMN blev                 FORMAT 90           HEADING "BTree|Level"
COLUMN leaf_blocks          FORMAT 999,990      HEADING "Leaf|Blocks"
COLUMN distinct_keys        FORMAT 9,999,990    HEADING "Distinct|Keys"
COLUMN clustering_factor    FORMAT 999,990      HEADING "Cluster|Factor"

COLUMN avg_leaf_blocks_per_key FORMAT 99,990 HEADING "Leaf Blks|Per Key"
COLUMN avg_data_blocks_per_key FORMAT 99,990 HEADING "Data Blks|Per Key"

COLUMN column_position      FORMAT 990          HEADING "Col|Pos"
COLUMN col                  FORMAT A23          HEADING "Column|Details"

SELECT
    table_name, 
    num_rows, 
    blocks, 
    empty_blocks, 
    avg_space, 
    chain_cnt, 
    avg_row_len 
FROM
    dba_tables 
WHERE
    owner = UPPER(NVL('&&owner', USER)) 
    AND table_name = UPPER('&&table_name') 
/

SELECT  
    column_name, 
    DECODE(t.data_type, 
        'NUMBER', t.data_type || '(' || 
            DECODE(t.data_precision, 
                NULL, t.data_length || ')', 
                t.data_precision || ',' || t.data_scale || ')'
            ), 
        'DATE', t.data_type, 
        'LONG', t.data_type, 
        'LONG RAW', t.data_type, 
        'ROWID', t.data_type, 
        'MLSLABEL', t.data_type, 
        t.data_type || '(' || t.data_length || ')'
    ) || ' ' ||
    DECODE(t.nullable, 
        'N', 'NOT NULL', 
        'n', 'NOT NULL', 
         NULL
    ) col, 
    num_distinct, 
    density 
FROM
    dba_tab_columns t 
WHERE
    table_name = UPPER('&table_name') 
    AND owner = UPPER(NVL('&owner', USER)) 
/

SELECT
    index_name, 
    uniqueness, 
    blevel blev, 
    leaf_blocks, 
    distinct_keys, 
    avg_leaf_blocks_per_key, 
    avg_data_blocks_per_key, 
    clustering_factor  
FROM
    dba_indexes 
WHERE
    table_name = UPPER('&table_name') 
    AND table_owner = UPPER(NVL('&owner', USER)) 
/ 

BREAK ON index_name

SELECT  
    i.index_name,  
    i.column_name,  
    i.column_position,  
    DECODE(t.data_type, 
        'NUMBER', t.data_type || '(' || 
         DECODE(t.data_precision, 
            NULL, t.data_length || ')', 
            t.data_precision || ',' || t.data_scale || ')'
         ), 
        'DATE', t.data_type, 
        'LONG', t.data_type, 
        'LONG RAW', t.data_type, 
        'ROWID', t.data_type, 
        'MLSLABEL', t.data_type, 
        t.data_type || '(' || t.data_length || ')'
    ) || ' ' || 
    DECODE(t.nullable, 
        'N', 'NOT NULL', 
        'n', 'NOT NULL', 
        NULL
    ) col 
FROM
    dba_ind_columns i,
    dba_tab_columns t 
WHERE
    i.table_name = UPPER('&table_name') 
    AND owner = UPPER(NVL('&owner', USER)) 
    AND i.table_name = t.table_name  
    AND t.column_name = i.column_name 
ORDER BY
    index_name,
    column_position 
/ 
@_END
