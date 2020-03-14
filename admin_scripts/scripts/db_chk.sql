REM
REM  ORACLE PERFORMANCE OVERVIEW
REM
REM  Created by: Mark D. Scull, Oracle Field Support 
REM  On: June 20, 1996
REM  Last Modified: May 1, 1998 by S.S.
REM

@_BEGIN
@_WTITLE "DATABASE CHECK INFORMATION"

SELECT name, created, log_mode FROM v$database;


@_WTITLE "DB BLOCK BUFFER - HIT RATIO"
 
COLUMN "Physical Reads"     FORMAT 9,999,999,999,999
COLUMN "Consistent Gets"    FORMAT 9,999,999,999,999
COLUMN "DB Block Gets"      FORMAT 9,999,999,999,999
COLUMN "% Hit Ratio"        FORMAT 999.99
 
SELECT
    pr.value "Physical Reads",
    cg.value "Consistent Gets",
    bg.value "DB Block Gets",
    ROUND((1 - (pr.value / (bg.value + cg.value))) * 100, 2) "% Hit Ratio"
FROM
    v$sysstat pr,
    v$sysstat bg,
    v$sysstat cg
WHERE
    pr.name = 'physical reads'
    AND bg.name = 'db block gets'
    AND cg.name = 'consistent gets'
/

PROMPT
PROMPT NOTE: If hit ratio is less than 70%, increase DB_BLOCK_BUFFERS.


@_WTITLE "SHARED POOL SIZE - GETS AND MISSES"

COLUMN "Executions"             FORMAT 9,999,999,990
COLUMN "Cache Misses Executing" FORMAT 9,999,999,990
COLUMN "Data Dictionary Gets"   FORMAT 9,999,999,999
COLUMN "Get Misses"             FORMAT 9,999,999,999
COLUMN "% Ratio"                FORMAT 999.99

SELECT
    SUM(pins) "Executions",
    SUM(reloads) "Cache Misses Executing",
    (SUM(reloads) / SUM(pins) * 100) "% Ratio"
FROM
    v$librarycache
/

PROMPT
PROMPT NOTE: If "% Ratio" is above 1%, increase SHARED_POOL_SIZE.


@_WTITLE "SHARED POOL SIZE (DICTIONARY GETS)"

SELECT
    SUM(gets) "Data Dictionary Gets",
    SUM(getmisses) "Get Misses",
    100 * (SUM(getmisses) / SUM(gets)) "% Ratio"
FROM
    v$rowcache
/

PROMPT
PROMPT NOTE: If "% Ratio" is above 12%, increase SHARED_POOL_SIZE.


@_WTITLE "LOG BUFFERS"

SELECT
    SUBSTR(name, 1, 25) Name,
    SUBSTR(value, 1, 15) "VALUE (Near 0?)"
FROM
    v$sysstat
WHERE
    name = 'redo log space requests'
/

PROMPT
PROMPT NOTE: If the VALUE is not near 0, increase LOG_BUFFER.


@_WTITLE "REDO WAITS"

COLUMN event FORMAT A35
COLUMN ratio FORMAT 999.99

SELECT
    event,
    total_waits,
    total_timeouts,
    100 * (total_timeouts / total_waits) ratio,
    time_waited,
    average_wait
FROM
    v$system_event
WHERE
    event LIKE 'log %'
ORDER BY
    event
/

PROMPT
PROMPT NOTE: Look for 'log file space/switch' parameter to determine LOG_BUFFER increase.


@_WTITLE "REDO LATCH CONTENTION"

COLUMN name             FORMAT A20
COLUMN WILLING_TO_WAIT  FORMAT 999.99
COLUMN "IMMEDIATE"      FORMAT 999.99

SELECT
    name,
    gets,
    misses,
    DECODE(gets, 0, 0, (100 * (misses / gets))) WILLING_TO_WAIT,
    sleeps,
    immediate_gets,
    immediate_misses,
    DECODE(immediate_gets, 0, 0,
        (100 * (immediate_misses / (immediate_gets + immediate_misses)))) "IMMEDIATE"
FROM
    v$latch
WHERE
    name LIKE 'redo%'
ORDER BY
    name
/

PROMPT
PROMPT NOTE (For SMP only): If WILLING_TO_WAIT and IMMEDIATE is less than 1%,
PROMPT increase LOG_SIMULTANEOUS_COPIES to twice # of CPU's, and decrease
PROMPT LOG_SMALL_ENTRY_MAX_SIZE in INIT.ORA file.


@_WTITLE "TABLESPACE USAGE"

COLUMN "Total Bytes"    FORMAT 9,999,999,999,999
COLUMN "Oracle Blocks"  FORMAT 9,999,999,999
COLUMN "Bytes Free"     FORMAT 9,999,999,999,999
COLUMN "Bytes Used"     FORMAT 9,999,999,999,999
COLUMN "% Free"         FORMAT 9999.999
COLUMN "% Used"         FORMAT 9999.999

CLEAR BREAKS
CLEAR COMPUTES

BREAK ON REPORT
COMPUTE SUM OF "Total Bytes"    ON REPORT
COMPUTE SUM OF "Oracle Blocks"  ON REPORT
COMPUTE SUM OF "Bytes Free"     ON REPORT
COMPUTE SUM OF "Bytes Used"     ON REPORT
COMPUTE AVG OF "% Free"         ON REPORT
COMPUTE AVG OF "% Used"         ON REPORT

SELECT
    SUBSTR(fs.file_id, 1, 3) "ID#",
    fs.tablespace_name,
    df.bytes "Total Bytes",
    df.blocks "Oracle Blocks",
    SUM(fs.bytes) "Bytes Free",
    (100 * ((SUM(fs.bytes)) / df.bytes)) "% Free",
    df.bytes - SUM(fs.bytes) "Bytes Used",
    (100 * ((df.bytes - SUM(fs.bytes)) / df.bytes)) "% Used"
FROM
    sys.dba_data_files df,
    sys.dba_free_space fs
WHERE
    df.file_id(+) = fs.file_id
GROUP BY
    fs.file_id,
    fs.tablespace_name,
    df.bytes,
    df.blocks
ORDER BY
    fs.tablespace_name
/

PROMPT
PROMPT NOTE: If a tablespace has all datafiles with "% Used" greater 
PROMPT than 80%, it may need more datafiles added.


@_WTITLE "DISK ACTIVITY"

COLUMN "File Name"  FORMAT A35
COLUMN "File Total" FORMAT 999,999,999,990

SELECT
    SUBSTR(df.file#, 1, 2) "ID",
    RPAD(name, 35, '.') "File Name",
    RPAD(SUBSTR(phyrds, 1, 10), 10, '.') "Phy Reads",
    RPAD(SUBSTR(phywrts, 1, 10), 10, '.') "Phy Writes",
    RPAD(SUBSTR(phyblkrd, 1, 10), 10, '.') "Blk Reads",
    RPAD(SUBSTR(phyblkwrt, 1, 10), 10, '.') "Blk Writes",
    RPAD(SUBSTR(readtim, 1, 9), 9, '.') "Read Time",
    RPAD(SUBSTR(writetim, 1, 10), 10, '.') "Write Time",
    (SUM(phyrds + phywrts + phyblkrd + phyblkwrt + readtim)) "File Total"
FROM
    v$filestat fs,
    v$datafile df
WHERE
    fs.file# = df.file#
GROUP BY
    df.file#,
    df.name,
    phyrds,
    phywrts,
    phyblkrd,
    phyblkwrt,
    readtim,
    writetim
ORDER BY
    SUM(phyrds + phywrts + phyblkrd + phyblkwrt + readtim) DESC,
    df.name
/

PROMPT
PROMPT NOTE: To reduce disk contention, insure that datafiles with the greatest
PROMPT activity are not on the same disk.


@_WTITLE "DISK READS MAXIMUM USER / SQL TEXT"

COLUMN sql_text FORMAT A60 WORD_WRAP

SELECT
    username,
    sql_text
FROM
    v$sqlarea,
    v$session
WHERE
    address = sql_address
    AND username IS NOT NULL
    AND disk_reads / executions = (
        SELECT
            MAX(disk_reads / executions)
        FROM
            v$sqlarea, v$session
        WHERE
            address = sql_address
            AND username IS NOT NULL
    )
/

PROMPT
PROMPT NOTE: SQL statements that are used often, or are very large, should
PROMPT be pinned in the SHARED_POOL and/or written with variables to insure
PROMPT that it stays active in the SHARED_POOL.


@_WTITLE "FRAGMENTATION"

SELECT
    SUBSTR(de.owner, 1, 8) "Owner",
    SUBSTR(de.segment_type, 1, 8) "Seg Type",
    SUBSTR(de.segment_name, 1, 35) "Table Name (Segment)",
    SUBSTR(de.tablespace_name, 1, 20) "Tablespace Name",
    COUNT(*) "Defrag NEED",
    SUBSTR(df.name, 1, 40) "DataFile Name"
FROM
    sys.dba_extents de,
    v$datafile df
WHERE
    de.owner <> 'SYS'
    AND de.file_id = df.file#
    AND de.segment_type = 'TABLE'
GROUP BY
    de.owner,
    de.segment_name,
    de.segment_type,
    de.tablespace_name,
    df.name
HAVING
    COUNT(*) > 1
ORDER BY
    COUNT(*) DESC
/

PROMPT
PROMPT NOTE: The more fragmented a segment is, the more i/o needed to read
PROMPT that info.  Defragments this tables regularly to insure extents
PROMPT ('Defrag NEED') do not get much above 2.


@_WTITLE "ROLLBACK SEGMENTS"

SELECT
    SUBSTR(sys.dba_rollback_segs.segment_id, 1, 5) "ID#",
    SUBSTR(sys.dba_segments.owner, 1, 8) "Owner",
    SUBSTR(sys.dba_segments.tablespace_name, 1, 17) "Tablespace Name",
    SUBSTR(sys.dba_segments.segment_name, 1, 17) "Rollback Name",
    SUBSTR(sys.dba_rollback_segs.initial_extent, 1, 10) "INI_Extent",
    SUBSTR(sys.dba_rollback_segs.next_extent, 1, 10) "Next Exts",
    SUBSTR(sys.dba_segments.min_extents, 1, 5) "MinEx",
    SUBSTR(sys.dba_segments.max_extents, 1, 5) "MaxEx",
    SUBSTR(sys.dba_segments.pct_increase, 1, 5) "%Incr",
    SUBSTR(sys.dba_segments.bytes, 1, 15) "Size (Bytes)",
    SUBSTR(sys.dba_segments.extents, 1, 6) "Extent#",
    SUBSTR(sys.dba_rollback_segs.status, 1, 10) "Status"
FROM
    sys.dba_segments,
    sys.dba_rollback_segs
WHERE
    sys.dba_segments.segment_name = sys.dba_rollback_segs.segment_name
    AND sys.dba_segments.segment_type = 'ROLLBACK'
ORDER BY
    sys.dba_rollback_segs.segment_id
/


@_WTITLE "ROLLBACK SEGMENT STATUS"

SELECT
    SUBSTR(v$rollname.name, 1, 20) "Rollback_Name",
    SUBSTR(V$rollstat.extents, 1, 6) "EXTENT",
    v$rollstat.rssize,
    v$rollstat.writes,
    SUBSTR(v$rollstat.xacts, 1, 6) "XACTS",
    v$rollstat.gets,
    SUBSTR(v$rollstat.waits, 1, 6) "WAITS",
    v$rollstat.hwmsize,
    v$rollstat.shrinks,
    SUBSTR(v$rollstat.wraps, 1, 6) "WRAPS",
    SUBSTR(v$rollstat.extends, 1, 6) "EXTEND",
    v$rollstat.aveshrink,
    v$rollstat.aveactive
FROM
    v$rollname,
    v$rollstat
WHERE
    v$rollname.usn = v$rollstat.usn
ORDER BY
    v$rollname.usn
/


@_WTITLE "ROLLBACK SEGMENT MAPPING"

SELECT
    r.name rollback_name,
    p.pid oracle_pid,
    p.spid vms_pid,
    NVL(p.username,'NO TRANSACTION') transaction,
    p.terminal terminal
FROM
    v$lock l,
    v$process p,
    v$rollname r
WHERE
    l.addr = p.addr(+)
    AND TRUNC(l.id1(+) / 65536) = r.usn
    AND l.type(+) = 'TX'
    AND l.lmode(+) = 6
ORDER BY
    r.name
/


@_WTITLE "REDO LOG HISTORY (BY DATE)"

REM
REM Oracle V8 and above have changed the 'time' column in the
REM v$log_history table to a 'stamp' column, so change time to stamp
REM in the following 'Redo Thread Log History (by date)' script if
REM you are using Oracle V8 and above.
REM

SELECT
    thread#, 
    SUBSTR(time, 1, 8) "Date",
    COUNT(SUBSTR(time, 1, 8)) "Count"
FROM
    v$log_history
GROUP BY
    thread#,
    SUBSTR(time, 1, 8)
ORDER BY
    thread#,
    SUBSTR(time, 1, 8) DESC
/

PROMPT
PROMPT NOTE: The 'Count' column is the number of log files created on a certain
PROMPT date. If this number is high, it may indicate a need to increase log file
PROMPT size and/or look at Archive Log Buffer Blocks and Size parameters.


@_WTITLE "DB BLOCK BUFFER - HIT RATIO BY USERS"

REM
REM Oracle V7.0 and earlier do not have v$sess_io table, so take
REM out the following 'DB Block Buffer - Hit Ratio by Users' script
REM if your are not running V7.1 and above.
REM

COLUMN MACHINE      FORMAT A25
COLUMN HIT_RATIO    FORMAT 999.99

SELECT
    username,
    machine,
    process,
    status,
    100 * (consistent_gets + block_gets - physical_reads) /
        (consistent_gets + block_gets) HIT_RATIO
FROM
    v$session,
    v$sess_io
WHERE
    v$session.sid = v$sess_io.sid
    AND (consistent_gets + block_gets) > 0
    AND username IS NOT NULL
/

PROMPT
PROMPT NOTE: If HIT_RATIO is below 70% for a user, look at what the
PROMPT user is doing and may be tune SQL statement.


@_WTITLE "CURRENT USERS"

COLUMN "DB UserName"    FORMAT A15
COLUMN "OS UserName"    FORMAT A15
COLUMN machine          FORMAT A10
COLUMN terminal         FORMAT A10

SELECT
    username "DB UserName",
    osuser "OS UserName",
    SUBSTR(object, 1, 25) Object,
    command,
    machine,
    terminal,
    process,
    status
FROM
    v$access a,
    v$session s
WHERE
    a.sid = s.sid
ORDER BY
    username
/


@_WTITLE "CURRENT SESSIONS"

COLUMN "OS Program Name" FORMAT A40

SELECT
    username "DB UserName",
    osuser "OS UserName",
    SUBSTR(command, 1, 3) CMD,
    machine,
    terminal,
    process,
    status,
    program "OS Program Name"
FROM
    v$session
WHERE
    type = 'USER'
ORDER BY
    username
/


@_WTITLE "CURRENT ACCESS"

REM
REM In Oracle V7.3 and above, the 'ob_typ' column was changed to 
REM 'type' in the v$access table, so change type to ob_typ in the
REM following script if running an Oracle version earlier than V7.3.
REM

SELECT
    sid,
    SUBSTR(owner, 1, 15) owner,
    SUBSTR(object, 1, 25) object,
    type
FROM
    v$access
ORDER BY
    owner
/

@_END
