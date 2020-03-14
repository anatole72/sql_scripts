REM
REM  Dictionary views, their columns and column descriptions
REM

PROMPT
PROMPT DICTIONARY VIEWS, THEIR COLUMNS AND COLUMN DESCRIPTIONS
PROMPT
ACCEPT nam PROMPT 'View name contains: '
ACCEPT clm PROMPT 'Column name contains: '
ACCEPT com PROMPT 'Column description contains: '

@_BEGIN
@_TITLE "DICTIONARY VIEWS COLUMNS"

COLUMN tab HEADING "VIEW NAME"          FORMAT A20 WORD_WRAPPED
COLUMN col HEADING "COLUMN NAME"        FORMAT A20 WORD_WRAPPED
COLUMN com HEADING "COLUMN DESCRIPTION" FORMAT A37 WORD_WRAPPED
BREAK ON tab SKIP 1

SELECT
    table_name  tab,
    column_name col,
    comments    com
FROM
    dict_columns
WHERE
    table_name LIKE UPPER('%&nam%') ESCAPE '\' AND
    column_name LIKE UPPER('%&clm%') ESCAPE '\' AND
    UPPER(comments) LIKE UPPER('%&com%') ESCAPE '\'
ORDER BY
    table_name,
    column_name
;

UNDEFINE nam clm com

@_END
