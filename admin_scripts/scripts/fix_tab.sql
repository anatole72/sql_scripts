REM
REM Fixed dictionary tables/views and view descriptions
REM

PROMPT
PROMPT FIXED DICTIONARY TABLES/VIEWS
PROMPT
ACCEPT name PROMPT 'Table/view name contains (ENTER for %): '
ACCEPT keyw PROMPT 'View definition contains (ENTER for %): '

@_BEGIN
@_TITLE "FIXED TABLES AND VIEWS"

COLUMN tab HEADING "FIXED TABLE/VIEW"   FORMAT A30
COLUMN def HEADING "VIEW DEFINITION"    FORMAT A48 WORD_WRAPPED
BREAK ON tab SKIP 1

SELECT
    t.name tab,
    NVL(d.view_definition, 'FIXED TABLE') def
FROM
    v$fixed_table t, 
    v$fixed_view_definition d
WHERE
    t.name LIKE UPPER('%&name%') ESCAPE '\'
    AND UPPER(NVL(d.view_definition, 'FIXED TABLE')) 
        LIKE UPPER('%&keyw%') ESCAPE '\'
    AND t.name = d.view_name (+)
ORDER BY
    t.name
;

UNDEFINE name
UNDEFINE keyw 

@_END
