REM
REM  Redo Log contention
REM

@_BEGIN
@_TITLE "REDO LOG CONTENTION INFO"

COLUMN name             FORMAT A15      HEADING "Name"
COLUMN gets             FORMAT 99999999 HEADING "Gets"
COLUMN misses           FORMAT 99999999 HEADING "Misses"
COLUMN immediate_gets   FORMAT 99999999 HEADING "Immediate|Gets"
COLUMN immediate_misses FORMAT 99999999 HEADING "Immediate|Misses"

SELECT
    name,
    gets,
    misses,
    immediate_gets,
    immediate_misses
FROM
    v$latch
WHERE
    name IN (
        'redo allocation',
        'redo copy'
    )  
/
@_END
