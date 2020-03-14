REM 
REM  Display backward-compatibility specific features
REM 
REM  Author: Mark Lang, 1998
REM  Notes:  Release 0.0.0.0.0 means feature has not been used
REM 

@_BEGIN
@_TITLE "BACKWARD-COMPATIBILITY SPECIFIC FEATURES"

COLUMN release FORMAT A19
COLUMN description FORMAT A50

DEFINE v1 = "INSTR(release, '.', 1, 1)"
DEFINE v2 = "INSTR(release, '.', 1, 2)"
DEFINE v3 = "INSTR(release, '.', 1, 3)"
DEFINE v4 = "INSTR(release, '.', 1, 4)"

SELECT
    type_id,
    release,
    description
FROM
    v$compatibility
ORDER BY
    LPAD(SUBSTR(release, 1, &&v1 - 1), 2) desc,
    LPAD(SUBSTR(release, &&v1 + 1, &&v2 - &&v1 - 1), 2) desc,
    LPAD(SUBSTR(release, &&v2 + 1, &&v3 - &&v2 - 1), 2) desc,
    LPAD(substr(release, &&v3 + 1, &&v4 - &&v3 - 1), 2) desc,
    LPAD(SUBSTR(release, &&v4 + 1), 2) desc,
    type_id
;

UNDEFINE src v1 v2 v3 v4

@_END

