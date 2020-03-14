REM
REM  Describes selectivity of given columns for a table
REM
REM  Author: Virag Saksena, Bjorn Schulze, Oracle US
REM

@_BEGIN

PROMPT
PROMPT SELECTIVITY OF COLUMNS FOR A TABLE
PROMPT

ACCEPT table_name   PROMPT 'Table name ([owner].table): '
ACCEPT col_list     PROMPT 'Columns separated by commas: '

COLUMN value2       FORMAT 99999999         NOPRINT
COLUMN "values"     FORMAT A25              HEADING '# of rows returned per|&col_list'
COLUMN "occurence"  FORMAT 9999999999999    HEADING '# of time these|# of rows returned'

SELECT
    DECODE(LEAST(col1, 20),
        col1, TO_CHAR(col1),
        DECODE(LEAST(col1, 100),
            col1 , (10 * TRUNC(col1 / 10) + 1) || ' - ' ||
                (10 * TRUNC(col1 / 10) + 10),
            (100 * TRUNC(col1 / 100) + 1) || ' - ' ||
                (100 * TRUNC(col1 / 100) + 100))) "Values",
    DECODE(LEAST(col1, 20),
        col1, col1,
        DECODE(LEAST(col1, 100),
            COL1 ,10 * TRUNC(col1 / 10),
            100 * TRUNC(col1 / 100))) value2,
    COUNT(*) occurence
FROM (
    SELECT COUNT(*) col1
    FROM &table_name
    GROUP BY &col_list
)
GROUP BY
    DECODE(LEAST(col1, 20),
        col1, TO_CHAR(col1),
        DECODE(LEAST(col1, 100),
            col1 , (10 * TRUNC(col1 / 10) + 1) || ' - ' ||
                (10 * TRUNC(col1 / 10) + 10),
            (100 * TRUNC(col1 / 100) + 1) || ' - ' ||
                (100 * TRUNC(col1 / 100) + 100))),
    DECODE(LEAST(col1, 20),
        col1, col1,
        DECODE(LEAST(col1, 100),
            COL1 ,10 * TRUNC(col1 / 10),
            100 * TRUNC(col1 / 100)))
ORDER BY
    2
/

@_END

