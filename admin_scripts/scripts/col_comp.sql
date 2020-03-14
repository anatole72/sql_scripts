REM 
REM  Compares columns in two tables
REM  Author:  Mark Lang, 1998
REM

@_BEGIN

PROMPT
PROMPT COMPARE COLUMNS IN TWO TABLES
PROMPT

ACCEPT own1 PROMPT "First table owner: "
ACCEPT nam1 PROMPT "First table name: "
PROMPT
ACCEPT own2 PROMPT "Second table owner: "
ACCEPT nam2 PROMPT "Second table name: "

COLUMN col1 FORMAT A25
COLUMN col2 FORMAT A25
COLUMN text FORMAT A27 WRAP

SELECT
    c1.column_name col1,
    c2.column_name col2,
    DECODE(
        c2.data_type,
        NULL, 'Not found in 2',
        c1.data_type, c1.data_type ||
            DECODE(
                c1.data_type,
                'VARCHAR2', DECODE(
                    c1.data_length,
                    c2.data_length, '',
                    ' ' || TO_CHAR(c1.data_length) || '/' || TO_CHAR(c2.data_length)),
                'CHAR', DECODE(
                    c1.data_length,
                    c2.data_length, '',
                    ' ' || TO_CHAR(c1.data_length) || '/' || TO_CHAR(c2.data_length)),
                ''
            ),
        c1.data_type || '/' || c2.data_type
    ) text
FROM
    dba_tab_columns c1,
    dba_tab_columns c2
WHERE
    c1.owner = UPPER('&&own1')
    AND c1.table_name = UPPER('&&nam1')
    AND c2.owner(+) = UPPER('&&own2')
    AND c2.table_name(+) = UPPER('&&nam2')
    AND c1.column_name = c2.column_name(+)
UNION ALL
SELECT
    NULL,
    c2.column_name,
    'Not found in 1'
FROM
    dba_tab_columns c2
WHERE
    owner = UPPER('&&own2')
    AND table_name = UPPER('&&nam2')
    AND NOT EXISTS (
        SELECT 0
        FROM dba_tab_columns
        WHERE owner = UPPER('&&own1')
        AND table_name = UPPER('&&nam1')
        AND column_name = c2.column_name
    )
ORDER BY
    1, 2
;

@_END


