REM
REM  Information about latches with misses.
REM
REM  According to "Oracle7: Pefrormance Tuning" the Hit Ratio
REM  should be more than 98%, violations are marked by "!".
REM

@_BEGIN
@_TITLE "MISSING LATCHES"

SET NUMWIDTH 8
DEFINE thres = 0.98

COLUMN name     FORMAT A25      HEADING Name
COLUMN gets                     HEADING Gets
COLUMN misses                   HEADING Misses
COLUMN hit_rat  FORMAT 999.9    HEADING "% Hit|Ratio"
COLUMN bad      FORMAT A1       HEADING "!"
COLUMN i_gets                   HEADING Immedia|Gets
COLUMN i_misses                 HEADING Immedia|Misses
COLUMN sleeps                   HEADING Sleeps

SELECT 
    name, 
    gets, 
    misses, 
    (gets - misses) / DECODE(gets, 0, 1, gets) * 100 hit_rat,
    DECODE(
        SIGN((gets - misses) / DECODE(gets, 0, 1, gets) - &&thres),
        1, ' ', '!'
        ) bad,
    immediate_gets i_gets, 
    immediate_misses i_misses,
    sleeps
FROM 
    v$latch
WHERE 
    misses > 0
    OR immediate_misses > 0
ORDER BY
    hit_rat 
/

UNDEFINE thres
@_END
