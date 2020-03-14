REM 
REM  Display comments on a table
REM

PROMPT
PROMPT TABLE COMMENTS
PROMPT

ACCEPT own PROMPT "Table owner like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "
ACCEPT com PROMPT "Table comment like (ENTER for all): "

@_BEGIN
@_TITLE "TABLE COMMENTS"

COLUMN name     FORMAT A25
COLUMN comments FORMAT A53 WORD

SELECT
    owner || '.' || table_name name,
    comments
FROM
    dba_tab_comments
WHERE
    owner LIKE UPPER(DECODE('&&own', NULL, '%', '&&own'))
    AND table_name LIKE UPPER(DECODE('&&nam', NULL, '%', '&&nam'))
    AND UPPER(comments) LIKE UPPER(DECODE('&&com', NULL, '%', '&&com'))
ORDER BY
    1
;

UNDEFINE own nam com
@_END

