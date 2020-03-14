REM 
REM  Display database size indicators
REM  Author: Mark Lang, 1998
REM 

@_BEGIN

DEFINE l = "30"

COLUMN sort1 NOPRINT
COLUMN text FORMAT A50 HEADING "DATABASE SIZING INDICATORS"

SELECT
    0 sort1,
    RPAD('Database name', &&l) || name text
FROM
    v$database
UNION
SELECT
    1,
    RPAD('Devices used', &&l) || LTRIM(TO_CHAR(
        COUNT(DISTINCT SUBSTR(name, 1, LEAST(
            DECODE(INSTR(name, '/', 2), 0, LENGTH(name), INSTR(name, '/', 2)),
            DECODE(INSTR(name, '\', 2), 0, LENGTH(name), INSTR(name, '\', 2)),
            DECODE(INSTR(name, ':', 2), 0, LENGTH(name), INSTR(name, ':', 2))
    ))), 
    '990'))
FROM
    v$datafile
UNION
SELECT 
    2,
    RPAD('Datafiles', &&l) || LTRIM(TO_CHAR(COUNT(*), '9,990'))
FROM
    v$datafile
UNION
SELECT
    3,
    RPAD('Total size (G)', &&l) || LTRIM(TO_CHAR(SUM(bytes) / (1024 * 1024 * 1024),
        '990.99'))
FROM
    v$datafile
UNION
SELECT
    4,
    RPAD('Tables/indexes', &&l) ||
        LTRIM(TO_CHAR(SUM(DECODE(type, 2, 1, 0)), '999,990')) || '/' ||
        LTRIM(TO_CHAR(SUM(DECODE(type, 1, 1, 0)), '999,990'))
FROM
    sys.obj$
WHERE
    owner# <> 0 
UNION
SELECT
    5,
    RPAD('Users', &&l) || LTRIM(TO_CHAR(COUNT(*), '9,990'))
FROM
    sys.user$
WHERE
    type = 1
UNION
SELECT
    6,
    RPAD('Sessions highwater', &&l) ||
        LTRIM(TO_CHAR(sessions_highwater, '9,990'))
FROM
    v$license
UNION
SELECT
    9,
    RPAD('SGA (M)', &&l) || LTRIM(TO_CHAR(SUM(value) / (1024 * 1024), '99,990.99'))
FROM
    v$sga
;

UNDEFINE l

@_END


