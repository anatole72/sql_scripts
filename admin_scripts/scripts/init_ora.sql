REM
REM  Recreate database init.ora
REM  Author: Mark Lang, 1998
REM 

PROMPT
PROMPT RECREATING THE INIT.ORA FILE
PROMPT
PROMPT Allowed print option:
PROMPT
PROMPT 0 - print all parameters (default option)
PROMPT 1 - print all, comment default parameters
PROMPT 2 - print only non-defaults parameters
PROMPT
ACCEPT opts PROMPT "Print option: " NUMBER
PROMPT

@_BEGIN

SET HEADING OFF
SET PAGESIZE 0
SET TERMOUT OFF
COLUMN name NEW_VALUE db NOPRINT
SELECT name FROM v$database;
COLUMN name CLEAR
SET TERMOUT ON

SELECT
    '# INIT.ORA for database ' || d.name || CHR(10) ||
    '# Generated on: ' || TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI:SS')
FROM
    v$database d
;
PROMPT
SELECT
    DECODE(TO_NUMBER(&&opts),
        1, DECODE(isdefault,
            'TRUE', '# ',
            DECODE(value, NULL, '# ', '')),
        DECODE(value, NULL, '# ', '')) || name || ' = ' || value
FROM
    v$parameter
WHERE
    TO_NUMBER(&&opts) < 2
    OR isdefault = 'TRUE'
ORDER BY
    name
;

UNDEFINE db opts
@_END

