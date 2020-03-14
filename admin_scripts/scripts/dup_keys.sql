REM  
REM  Finding Duplicate Keys in a Table
REM

@_BEGIN

SET HEADING OFF
SET PAGESIZE 0

ACCEPT tab PROMPT 'Table to check ([owner.]table): '
PROMPT
SELECT 'Table ' || UPPER('&&tab') FROM dual;
PROMPT
DESCRIBE &&tab

PROMPT
PROMPT Enter name(s) of column(s) which should be unique.  If more than
PROMPT one column is specified , you MUST seperate with commas.
PROMPT
ACCEPT cols PROMPT 'Column(s): '
PROMPT

@_TITLE "Duplicate keys &&tab"

SELECT
    ROWID,
    &&cols
FROM
    &&tab
WHERE
    ROWID NOT IN (
        SELECT MIN(ROWID)
        FROM &&tab
        GROUP BY &&cols
    )
/
@_END

