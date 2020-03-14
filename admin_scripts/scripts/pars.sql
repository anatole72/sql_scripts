REM
REM  INIT.ORA parameter information (for 7.3.3)
REM

PROMPT
PROMPT INIT.ORA PARAMETERS
PROMPT

ACCEPT nam PROMPT "Parameter like (ENTER for all): "
ACCEPT des PROMPT "Description like (ENTER for all): "

@_BEGIN
@_TITLE "INIT.ORA PARAMETERS"

COLUMN name         FORMAT A25  
COLUMN value        FORMAT A18  WORD_WRAP
COLUMN opt          FORMAT A3   HEADING "DSS|EEY|FSS"
COLUMN description  FORMAT A30  WORD_WRAP

SELECT 
    name,
    value,
    SUBSTR (isdefault, 1, 1)
        || SUBSTR (isses_modifiable, 1, 1)
        || SUBSTR (issys_modifiable, 1, 1) opt,
    description
FROM
    v$parameter
WHERE 
    UPPER(name) LIKE NVL(UPPER('&&nam'), '%') ESCAPE '\'
    AND UPPER(description) LIKE NVL(UPPER('&&des'), '%')
ORDER BY
    name
;

UNDEFINE nam des

@_END
