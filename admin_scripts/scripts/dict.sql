REM
REM  Dictionary views and their descriptions
REM

PROMPT
PROMPT DICTIONARY VIEWS AND THEIR DESCRIPTIONS
PROMPT
ACCEPT nam PROMPT 'View name contains: '
ACCEPT com PROMPT 'View description contains: '

@_BEGIN
@_TITLE "DICTIONARY VIEWS"

COLUMN "VIEW NAME" FORMAT A30
COLUMN DESCRIPTION FORMAT A48 WORD_WRAPPED

SELECT
    table_name "VIEW NAME",
    comments DESCRIPTION
FROM
    dictionary
WHERE
    table_name LIKE UPPER('%&nam%') ESCAPE '\' AND
    UPPER(comments) LIKE UPPER('%&com%') ESCAPE '\'
ORDER BY
    table_name
;

UNDEFINE nam com

@_END
