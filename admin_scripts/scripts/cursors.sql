REM 
REM  Display open cursors
REM  Author: Mark Lang, 1998
REM

PROMPT
PROMPT DISPLAY OPEN CURSORS
PROMPT
ACCEPT usr PROMPT "User name like (ENTER for all): "

@_BEGIN
SELECT
    user_name "USER NAME",
    COUNT(*) "CURSORS"
FROM
    v$open_cursor
WHERE
    user_name LIKE NVL(UPPER('&&usr'), '%')
GROUP BY
    user_name
;

PROMPT
COLUMN text FORMAT A40 HEADING "SUMMARY"
SELECT
    'Cursors (Sum): ' || TO_CHAR(SUM(COUNT(*)), '9999') || &&CR ||
    'Cursors (Min): ' || TO_CHAR(MIN(COUNT(*)), '9999') || &&CR ||
    'Cursors (Max): ' || TO_CHAR(MAX(COUNT(*)), '9999') || &&CR ||
    'Cursors (Avg): ' || TO_CHAR(AVG(COUNT(*)), '9990.99') || &&CR||
    'Users        : ' || TO_CHAR(COUNT(COUNT(*)), '9999') text
FROM
    v$open_cursor
WHERE
    user_name LIKE NVL(UPPER('&&usr'), '%')
GROUP BY
    user_name
;

UNDEFINE usr
@_END

