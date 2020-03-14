REM
REM  Build a script to re-create user's functions, procedures, 
REM  packages or package bodies.
REM

PROMPT
PROMPT BUILD A SCRIPT TO RE-CREATE PL/SQL PROGRAM UNITS
PROMPT

ACCEPT obj_own  PROMPT "Object owner: "
ACCEPT obj_name PROMPT "Object name like (ENTER for all): "
ACCEPT obj_type -
    PROMPT "Object types ([P]rocedure, [F]unction, packa[G]e, [B]ody or ENTER for PFGB): "
PROMPT

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET LINESIZE 255
SET PAGESIZE 0
SET TRIMSPOOL ON

COLUMN text FORMAT A250 WORD_WRAP
COLUMN line NOPRINT

SELECT
    DECODE(line, 1,
        DECODE(rownum, 1, '', '/')
        || DECODE(rownum, 1, '', CHR(10))
        || 'CREATE OR REPLACE '
        || CHR(10), '')
    || text text,
    line 
FROM
    dba_objects s1,
    dba_source s2
WHERE
    INSTR(
        NVL(UPPER('&&obj_type'), 'PFGB'),
        DECODE(s1.object_type,
            'PROCEDURE',    'P',
            'FUNCTION',     'F',
            'PACKAGE',      'G',
            'PACKAGE BODY', 'B',
            '?'
        )
    ) > 0
    AND s1.owner = UPPER('&&obj_own')
    AND s1.object_name LIKE NVL(UPPER('&&obj_name'), '%')
    AND s1.object_type = s2.type
    AND s1.owner = s2.owner
    AND s1.object_name = s2.name
ORDER BY
    s1.object_name,
    s1.object_type,
    line
;
SELECT '/' FROM DUAL;

UNDEFINE obj_own obj_name obj_type
@_END
