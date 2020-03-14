REM 
REM  Display I/O and hit ratio by session
REM 

PROMPT
PROMPT I/O AND HIT RATIO BY SESSION
PROMPT
ACCEPT ar PROMPT "Mode ((S)ystem, (U)ser, (A)ll, ENTER for S): "
DEFINE arg = "UPPER(REPLACE(NVL('&&ar', '%'), '%', 'S'))"

@_BEGIN
@_TITLE "I/O AND HIT RATIO BY SESSION"

COLUMN username             FORMAT A15
COLUMN sid                  FORMAT 9,990        HEADING "SID"
COLUMN logical_reads        FORMAT 9,999,990    HEADING "LOGRD"
COLUMN physical_reads       FORMAT 9,999,990    HEADING "PHYRD"
COLUMN block_changes        FORMAT 9,999,990    HEADING "BLKCHG"
COLUMN consistent_changes   FORMAT 9,990        HEADING "CONCHG"
COLUMN hit_ratio            FORMAT 0.999        HEADING "HIT%"
COLUMN wri_ratio            FORMAT 0.999        HEADING "WRI%"

SELECT
    DECODE(&&arg, 'A', 'TOTAL', MAX(s.username)) username,
    DECODE(&&arg, 'U', COUNT(*), 'A', COUNT(*), MAX(i.sid)) sid,
    SUM(i.block_gets + i.consistent_gets) logical_reads,
    SUM(i.physical_reads) physical_reads,
    SUM(i.block_changes) block_changes,
    SUM(i.consistent_changes) consistent_changes,
    1 - SUM(i.physical_reads) / SUM(i.block_gets + i.consistent_gets + 1) hit_ratio,
    SUM(i.block_changes) / sum(i.block_gets + i.consistent_gets + 1) wri_ratio
FROM
    v$sess_io i,
    v$session s
WHERE
    i.sid = s.sid
    and s.type = 'USER'
    and s.username IS NOT NULL
GROUP BY
    DECODE(&&arg, 'U', s.username, 'A', 1, i.sid)
ORDER BY
    7, 1, 2
;

UNDEFINE ar arg

@_END


