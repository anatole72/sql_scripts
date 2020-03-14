REM
REM  Latch sleeps report
REM 

@_BEGIN
@_TITLE "LATCH SLEEPS REPORT"

COLUMN name   FORMAT A40        HEADING Latch
COLUMN sleeps                   HEADING Sleeps
COLUMN gets   FORMAT 999999999  HEADING Gets
COLUMN ratio  FORMAT 990.09     HEADING "Sleeps /|Gets (%)"

SELECT 
    a.name,
    b.sleeps,
    b.gets,
    100.0 * b.sleeps / b.gets ratio 
FROM
    v$latchname a,
    v$latch b 
WHERE
    a.latch# = b.latch# 
    AND b.sleeps > 0
;

REM
REM The second script provides the ratios of various sleeps for the latches
REM

COLUMN name     FORMAT A17          HEADING Latch
COLUMN gets     FORMAT 999,999,990  HEADING Gets
COLUMN miss     FORMAT 90.9         HEADING Misses
COLUMN cspins   FORMAT A6           HEADING 'Spins|Sl06' 
COLUMN csleep1  FORMAT A6           HEADING 'Sl01|Sl07' 
COLUMN csleep2  FORMAT A6           HEADING 'Sl02|Sl08' 
COLUMN csleep3  FORMAT A6           HEADING 'Sl03|Sl09' 
COLUMN csleep4  FORMAT A6           HEADING 'Sl04|Sl10' 
COLUMN csleep5  FORMAT A6           HEADING 'Sl05|Sl11' 
 
SELECT
    a.name,
    a.gets gets,
    a.misses * 100 / DECODE(a.gets, 0, 1, a.gets) miss,
    TO_CHAR(a.spin_gets * 100 / DECODE(a.misses, 0, 1, a.misses), '000.0') || 
        TO_CHAR(a.sleep6 * 100 / DECODE(a.misses, 0, 1, a.misses), '000.0') cspins,
    TO_CHAR(a.sleep1 * 100 / DECODE(a.misses, 0, 1, a.misses), '000.0') || 
        TO_CHAR(a.sleep7 * 100 / DECODE(a.misses, 0, 1, a.misses), '000.0') csleep1,
    TO_CHAR(a.sleep2 * 100 / DECODE(a.misses, 0, 1, a.misses), '000.0') || 
        TO_CHAR(a.sleep8 * 100 / DECODE(a.misses, 0, 1, a.misses), '000.0') csleep2,
    TO_CHAR(a.sleep3 * 100 / DECODE(a.misses, 0, 1, a.misses), '000.0') || 
        TO_CHAR(a.sleep9 * 100 / DECODE(a.misses, 0, 1, a.misses), '000.0') csleep3,
    TO_CHAR(a.sleep4 * 100 / DECODE(a.misses, 0, 1, a.misses), '000.0') || 
        TO_CHAR(a.sleep10 * 100 / decode(a.misses, 0, 1, a.misses), '000.0') csleep4,
    TO_CHAR(a.sleep5 * 100 / DECODE(a.misses, 0, 1, a.misses), '000.0') || 
        TO_CHAR(a.sleep11 * 100 / DECODE(a.misses, 0, 1, a.misses), '000.0') csleep5 
FROM
    v$latch a 
WHERE
    a.misses <> 0 
ORDER BY
    2 DESC 
/ 

@_END
