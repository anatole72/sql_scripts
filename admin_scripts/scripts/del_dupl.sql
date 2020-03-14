REM
REM Deleting duplicate rows in a table
REM

@_BEGIN
SET PAGESIZE 0

PROMPT
PROMPT DELETE DUPLICATE ROWS IN A TABLE
PROMPT
ACCEPT tab PROMPT 'Table name ([owner.]table): '
PROMPT

SELECT 'Table ' || UPPER('&&tab') FROM dual;
DESCRIBE &&tab

PROMPT
PROMPT Enter name(s) of column(s) which should be unique.  If more than
PROMPT one column is specified , you MUST seperate with commas.
PROMPT
ACCEPT cols PROMPT 'Column(s): '
PROMPT

SET FEEDBACK ON
DELETE FROM &&tab
WHERE ROWID NOT IN (
    SELECT MIN(rowid)
    FROM &&tab
    GROUP BY &&cols
    )
/

@_CONFIRM "commit"
COMMIT;

@_END
