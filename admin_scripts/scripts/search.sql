REM 
REM  Search source code for patterns
REM

PROMPT
PROMPT SEARCH SOURCE CODE FOR PATTERNS
PROMPT

ACCEPT o PROMPT "Program owner like (ENTER for all): "
DEFINE own = "NVL(UPPER('&&o'), '%')"

ACCEPT n PROMPT "Program name like (ENTER for all): "
DEFINE nam = "NVL(UPPER('&&n'), '%')"

ACCEPT t PROMPT "Type ([P]rocedure [F]unction packa[G]e [B]ody or ENTER for all): "
DEFINE typ = "NVL(UPPER('&&t'), 'PFGB')"

ACCEPT s PROMPT "Search pattern: "
DEFINE src = "UPPER('&&s')"

ACCEPT w PROMPT "Surrounding lines ([+-]n, ENTER for 0): "
DEFINE win = "'&&w'"
DEFINE les = "DECODE(SUBSTR(&&win, 1, 1), '+', 0, TO_NUMBER(&&win))"
DEFINE mor = "DECODE(SUBSTR(&&win, 1, 1), '-', 0, TO_NUMBER(&&win))"

@_BEGIN
@_WTITLE "SEARCH RESULTS"

COLUMN program  FORMAT A43
COLUMN line     FORMAT 99999
COLUMN text     FORMAT A80
BREAK ON program SKIP 1

SELECT
    s.owner || '.' || s.name || ' (' || s.type || ')' program,
    s.line,
    s.text
FROM
    dba_source s
WHERE
    s.owner LIKE &&own
    AND s.name LIKE &&nam
    AND &&src IS NOT NULL
    AND (
        INSTR(&&typ, 'P') > 0 AND s.type = 'PROCEDURE'
        OR INSTR(&&typ, 'F') > 0 AND s.type = 'FUNCTION'
        OR INSTR(&&typ, 'G') > 0 AND s.type = 'PACKAGE'
        OR INSTR(&&typ, 'B') > 0 AND s.type = 'PACKAGE BODY'
    )
    AND (
        UPPER(s.text) LIKE &&src
        OR EXISTS (
            SELECT 0
            FROM dba_source
            WHERE owner = s.owner
            AND name = s.name
            AND type = s.type
            AND (line BETWEEN s.line - &&mor AND s.line + &&les)
            AND UPPER(text) LIKE &&src
        )
    )
ORDER BY
    s.owner,
    s.name,
    s.type,
    s.line
;

UNDEFINE o own
UNDEFINE n nam
UNDEFINE t typ
UNDEFINE s src
UNDEFINE w win
UNDEFINE les mor

@_END

