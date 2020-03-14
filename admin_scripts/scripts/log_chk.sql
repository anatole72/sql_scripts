REM
REM Redo log files and buffer tuning information
REM 

@_BEGIN

REM
REM This query lists waits for the redo log buffer. The waits can
REM usually be tuned by increasing the LOG_BUFFER parameter or by
REM tuning your checkpoints. 
REM

@_TITLE 'REDO LOG BUFFER WAITS'

COLUMN name     FORMAT A30      HEADING "System Statistic"
COLUMN value    FORMAT 999999   HEADING "Value"
COLUMN comm     FORMAT A40      HEADING "Comment"

SELECT 
    name, 
    value,
    DECODE (value, 0, 'OK', 'Increase LOG_BUFFER') comm
FROM 
    v$sysstat
WHERE 
    name IN (
        'redo log space requests', 
        'redo buffer allocation retries'
    )
;

REM
REM Any waits for 'log file parallel write' in V$SYSTEM_EVENT
REM indicate a possible I/O problem with the log files.
REM

@_TITLE 'LOG FILE WAITS'

COLUMN event        FORMAT A30      HEADING "System Event"
COLUMN total_waits  FORMAT 999999   HEADING "Waits"
COLUMN comm         FORMAT A40      HEADING "Comment"

SELECT 
    event, 
    total_waits,
    DECODE (total_waits, 0, 'OK', 'Redo logs I/O problems') comm
FROM 
    v$system_event
WHERE 
    event IN (
        'log file parallel write'
    )
;

@_TITLE 'CHECKPOINT WAITS'

COLUMN name     FORMAT A32      HEADING "System Statistic"
COLUMN value    FORMAT 999999   HEADING "Value"

SELECT 
    name, 
    value
FROM 
    v$sysstat
WHERE 
    name IN (
        'background checkpoints started', 
        'background checkpoints completed'
    )
;

PROMPT
PROMPT Is above system statistics differ by more than 1, checkpoints are
PROMPT not completing between log switchs. You need larger log files.

@_TITLE "REDO LATCH CONTENTION (SMP ONLY)"

COLUMN name     FORMAT A20      HEADING "Redo Latch"
COLUMN gets     FORMAT 999999   HEADING "Gets"
COLUMN misses   FORMAT 99999    HEADING "Misses"
COLUMN igets    FORMAT 999999   HEADING "Immediate|Gets"
COLUMN imisses  FORMAT 99999    HEADING "Immediate|Misses"
COLUMN pct_mis  FORMAT 990.00   HEADING "Misses%"
COLUMN bad_mis  FORMAT A1       HEADING "!"
COLUMN pct_imis FORMAT 990.00   HEADING "Immediate|Misses%"
COLUMN bad_imis FORMAT A1       HEADING "!"

SELECT
    ln.name,
    gets,
    misses,
    immediate_gets igets,
    immediate_misses imisses,
    DECODE(gets, 0, 0, misses / gets * 100) pct_mis,
    DECODE(SIGN(DECODE(gets, 0, 0, misses / gets * 100) - 0.01),
    1, '!', '') bad_mis,
    DECODE(immediate_gets + immediate_misses, 0, 0, immediate_misses /
        (immediate_gets + immediate_misses) * 100) pct_imis,
    DECODE(SIGN(DECODE(immediate_gets + immediate_misses, 0, 0,
        immediate_misses / (immediate_gets + immediate_misses) * 100) - 0.01),
        1, '!', '') bad_imis
FROM
    v$latch l,
    v$latchname ln
WHERE
    ln.name IN (
        'redo allocation',
        'redo copy'
    )
    AND ln.latch# = l.latch#
ORDER BY
    ln.name
;

PROMPT
PROMPT Contention for a latch may be affecting performance if either of these
PROMPT conditions is true: 1) if the ratio of MISSES to GETS (Misses%) exceeds
PROMPT 1%; 2) if the ratio of IMMEDIATE_MISSES to the sum of IMMEDIATE_GETS and
PROMPT IMMEDIATE_MISSES (Immediate Misses%) exceeds 1%. If either of these
PROMPT conditions is true for a latch, try to reduce contention for that latch.
PROMPT
PROMPT To reduce contention for the redo allocation latch, you should minimize
PROMPT the time that any single process holds the latch. To reduce this time,
PROMPT reduce copying on the redo allocation latch. Decreasing the value of the
PROMPT LOG_SMALL_ENTRY_MAX_SIZE initialization parameter reduces the number and
PROMPT size of redo entries copied on the redo allocation latch.
PROMPT 
PROMPT If you observe contention for redo copy latches, add more latches. To
PROMPT increase the number of redo copy latches, increase the value of
PROMPT LOG_SIMULTANEOUS_COPIES. It can help to have up to twice as many redo copy
PROMPT latches as CPUs available to your Oracle instance.
@_END
