REM
REM  List source code
REM 

PROMPT
PROMPT LIST SOURCE CODE
PROMPT
ACCEPT own PROMPT "Program owner: "
ACCEPT nam PROMPT "Program name: "
ACCEPT typ PROMPT "Program type ((P)rocedure, (F)unction, packa(G)e, (B)ody): "
ACCEPT frl PROMPT "From line (ENTER for first): " NUMBER
ACCEPT tol PROMPT "To line (ENTER for last): " NUMBER
ACCEPT num PROMPT "Print numbers (Y/(N)): "
PROMPT

@_BEGIN
SET HEADING OFF
SET PAGESIZE 0

COLUMN text FORMAT A80 WRAP

SELECT
    DECODE(UPPER('&&num'),
        'Y', LPAD(TO_CHAR(line), 5) || ': ',
        ''
    ) || text text
FROM
    dba_source
WHERE
    owner = UPPER('&&own')
    AND name = UPPER('&&nam')
    AND type = DECODE(UPPER('&&typ'),
        'P', 'PROCEDURE',
        'F', 'FUNCTION',
        'G', 'PACKAGE',
        'B', 'PACKAGE BODY',
        '?')
    AND line BETWEEN
        DECODE(SIGN(&&frl), -1, 1, 0, 1, &&frl)
        AND DECODE(SIGN(&&tol), -1, 99999999, 0, 99999999, &&tol)
;

UNDEFINE own nam typ frl tol num

@_END

