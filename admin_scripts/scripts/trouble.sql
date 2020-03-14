@_BEGIN
SET FEEDBACK ON

PROMPT ############################################################
PROMPT
PROMPT O R A C L E   T r o u b l e s h o o t e r   V 0 . 2
PROMPT
PROMPT A Fast Overview of the State of a Troubled System
PROMPT
PROMPT ############################################################ 
PROMPT
PROMPT Script TROUBLE.SQL should be executed via SQL*Plus under 
PROMPT SYS account. The results of execution are logged into 
PROMPT TROUBLE.LOG in the current catalog.
PROMPT
PROMPT
PROMPT ************************************************************
PROMPT A QUICK LOOK
PROMPT
PROMPT The V$SESSION_WAIT view lists what each session is currently
PROMPT waiting for and what the session last waited for (in 1/1000
PROMPT sec.)
PROMPT
PROMPT Important events:
PROMPT
PROMPT * free buffer waits (DBWR not writing frequently enough;
PROMPT increase number of checkpoints)
PROMPT
PROMPT * latch free (contention for latches; a corrective action 
PROMPT is dependent upon the latch)
PROMPT
PROMPT * buffer busy waits (I/O contention or Parallel Server 
PROMPT contention for data blocks; tune I/O and distribute data)
PROMPT
PROMPT * db file sequential read (I/O contention, improperly tuned
PROMPT SQL)
PROMPT
PROMPT * db file scattered read (too many table scans; distribute
PROMPT data and tune SQL)
PROMPT
PROMPT * db file parallel write (not checkpointing frequently 
PROMPT enough; increase number of checkpoints)
PROMPT
PROMPT * undo segment extension (too much dynamic extension/
PROMPT shrinking of rollback segments; prevent RS's from 
PROMPT resizing by appropriately sizing them)
PROMPT
PROMPT * undo segment tx slot (not enough rollback segments;  
PROMPT create additional RS's)
PROMPT
PROMPT Output of the query:

COLUMN event FORMAT A40
SELECT 
    sid, 
    event, 
    wait_time
FROM 
    v$session_wait
ORDER BY 
    wait_time DESC, 
    event
;  

PROMPT Summary of the current waits:

SELECT 
    event,
    SUM(DECODE(wait_time, 0, 0, 1)) "Prev Waits",
    SUM(DECODE(wait_time, 0, 1, 0)) "Curr Waits",
    COUNT(*) "Total Waits"
FROM
    v$session_wait
GROUP BY
    event
ORDER BY
    4
;

PROMPT Summary of waits on the system since the instance was started:

SELECT
    event,
    total_waits
FROM
    v$system_event
ORDER BY
    2 DESC
;

PROMPT ************************************************************
PROMPT SGA 
PROMPT
PROMPT Summary information on the size of the main components of
PROMPT the System Global Area:

SELECT 
    name, bytes  
FROM
    v$sgastat
WHERE
    name IN (
        'db_block_buffers',
        'log_buffer',
        'dictionary cache',
        'sql area',
        'library cache',
        'free memory'
    )
;

PROMPT ************************************************************
PROMPT BUFFER HIT RATIO 
PROMPT
PROMPT Buffer Hit Ratio is percentage of time that requested data 
PROMPT are found in the data cache. This ratio should be more 70%, 
PROMPT else increase DB_BLOCK_BUFFERS in init.ora.
 
COLUMN "Logical Reads" FORMAT 99,999,999,999 
COLUMN "Phys Reads" FORMAT 999,999,999 
COLUMN "Phys Writes" FORMAT 999,999,999
 
SELECT 
    a.value + b.value "Logical Reads", 
    c.value "Phys Reads", 
    d.value "Phys Writes", 
    ROUND(100 * 
        ((a.value + b.value) - c.value)/ 
         (a.value + b.value)
    ) "BUFFER HIT RATIO (%)" 
FROM 
    v$sysstat a, 
    v$sysstat b, 
    v$sysstat c, 
    v$sysstat d 
WHERE 
    a.statistic# = 37 
    AND b.statistic# = 38 
    AND c.statistic# = 39 
    AND d.statistic# = 40
; 

PROMPT ************************************************************
PROMPT CUMULATIVE HIT RATIO (another way to calculate)
PROMPT
PROMPT The hit ratio is a measure of the frequency with which 
PROMPT requests for data (logical reads) are satisfied via data that
PROMPT is already in memory (requiring no physical reads from disk).
PROMPT The statistics in V$SYSSTAT show the cumulative hit ratio
PROMPT since the instance was started. The physical I/O associated 
PROMPT with the initial population of an instance after startup will
PROMPT slightly depress the hit ratio value. For an OLTP application,
PROMPT try to attain an overall database hit ratio of 98% or better.
PROMPT For a batch-intensive application, the hit ratio should exceed
PROMPT 89%. If not, increase DB_BLOCK_BUFFERS in init.ora or tune 
PROMPT queries in the application.
  
SELECT 
    SUM(DECODE(name, 'consistent gets', value, 0)) "Consistent Gets",
    SUM(DECODE(name, 'db block gets', value, 0)) "DB Block Gets",
    SUM(DECODE(name, 'physical reads', value, 0)) "Physical Reads",
    ROUND(((
        SUM(DECODE(name, 'consistent gets', value, 0)) +
        SUM(DECODE(name, 'db block gets', value, 0)) -
        SUM(DECODE(name, 'physical reads', value, 0)) ) / (
        SUM(DECODE(name, 'consistent gets', value, 0)) +
        SUM(DECODE(name, 'db block gets', value, 0))))
    * 100, 2) "HIT RATIO (%)"
FROM 
    v$sysstat 
; 
 
PROMPT ************************************************************
PROMPT LIBRARY CACHE MISSES RATIO 
PROMPT 
PROMPT Library Cache Misses Ratio (RELOAD RATIO) is percentage of 
PROMPT executions of SQL resulted in reparsing. If more than 1% of 
PROMPT the pins resulted in reloads, then increase the SHARED_POOL_SIZE 
PROMPT in init.ora. You may increase the OPEN_CURSORS also. 

COLUMN "Executions" FORMAT 999,999,999 
COLUMN "Reloads" FORMAT 999,999,999 

SELECT
    SUM(pins) "Executions", 
    SUM(reloads) "Reloads", 
    ROUND(
        SUM(reloads) / SUM(pins) * 100, 
        2
    ) "RELOAD RATIO (%)" 
FROM 
    v$librarycache
; 

PROMPT ************************************************************
PROMPT LIBRARY CACHE STATISTICS
PROMPT
PROMPT Get Hit Ratio is percentage of library object handles 
PROMPT the system has tried to get are cached (should be > 70%). 
PROMPT
PROMPT Pin Hit Ratio is percentage of library object the system 
PROMPT has tried to pin and access are cached (should be > 70%).
PROMPT
  
COLUMN "Reloads" FORMAT 999,999,999 

SELECT
    namespace, 
    TRUNC(gethitratio * 100) "Get Hit Ratio (%)", 
    TRUNC(pinhitratio * 100) "Pin Hit Ratio (%)", 
    reloads  
FROM 
    v$librarycache
; 

PROMPT Another query to show library cache statistics:

SELECT
    namespace,
    ROUND(
        DECODE(gethits, 0, 1, gethits) / DECODE(gets, 0, 1, gets)
        * 100, 2
    ) "Get Hit Ratio (%)",
    ROUND(
        DECODE(pinhits, 0, 1, pinhits) / DECODE(pins, 0, 1, pins)
        * 100, 2
    ) "Pin Hit Ratio (%)",
    reloads
FROM
    v$librarycache
;

PROMPT Library Cache Efficiency is the total percentage that a SQL
PROMPT statement did not need to be reload because it was already
PROMPT in the library cache. Should be close to 100%; if not, 
PROMPT increase SHARED_POOL_SIZE.

SELECT
    ROUND(SUM(pinhits) / SUM(pins) * 100, 2) 
    "LIBRARY CACHE EFFICIENCY (%)"
FROM
    v$librarycache
;

PROMPT ************************************************************
PROMPT SHARED POOL FREE MEMORY 
PROMPT
PROMPT Percentage of free space in the SGA shared pool area. Should 
PROMPT not drop below 5%. If not, increase SHARED_POOL_SIZE in 
PROMPT init.ora. The OPEN_CURSORS may also need to be increased.
 
SELECT
    ROUND(
        (SUM(DECODE(name, 'free memory', bytes, 0))
        / SUM(bytes))
        * 100, 2
    ) "SHARED POOL FREE MEMORY (%)"
FROM 
    v$sgastat
;
 
PROMPT ************************************************************
PROMPT DICTIONARY CACHE EFFICIENCY (HIT RATIO) 
PROMPT
PROMPT Should be higher than 85-90% else increase SHARED_POOL_SIZE 
PROMPT in init.ora. To tune the cache, examine its activity only 
PROMPT after your applications has been running, not just after 
PROMPT instance startup. The percentage should continue get closer 
PROMPT to 100% as the system stays "up".
 
COLUMN "Dict Gets" FORMAT 999,999,999 
COLUMN "Dict Cache Misses" FORMAT 999,999,999
 
SELECT
    SUM(gets) "Dict Gets", 
    SUM(getmisses) "Dict Cache Misses", 
    TRUNC(
        (1 - (SUM(getmisses) / SUM(gets))) * 100
    ) "DICT CACHE EFFICIENCY (%)"
FROM
    v$rowcache
; 

PROMPT ************************************************************
PROMPT RECURSIVE CALLS
PROMPT
PROMPT Recursive calls are SQL statements issued by the Oracle 
PROMPT itself when executing user SQL's. May show dinamic extention
PROMPT of tables or rollback segments. 
PROMPT
PROMPT If the RDBMS does not continue to make recursive calls after 
PROMPT start-up, your data dictinary cache is probably large enough
PROMPT for dictionary data. If the number of recursive calls 
PROMPT accumulates while your application is running, then there may 
PROMPT be dictionary cache misses.

SELECT
    SUBSTR(name, 1, 30) name,
    value
FROM
    v$sysstat
WHERE
    name = 'recursive calls'
;  

PROMPT ************************************************************
PROMPT REDO LOG BUFFER CONTENTION
PROMPT
PROMPT The values of "redo log space requests" should be near 0. 
PROMPT A nonzero value indicates that processes are waiting for 
PROMPT space in the buffer. If this value increase consistently, try 
PROMPT increasing the LOG_BUFFER in init.ora (by increments of 5%).

COLUMN name FORMAT A30
COLUMN value FORMAT 999,999,999 

SELECT 
    name, 
    value
FROM 
    v$sysstat 
WHERE 
    name = 'redo log space requests'
; 
 
PROMPT ************************************************************
PROMPT SORT EFFICIENCY 
PROMPT
PROMPT Sort Efficiency shows the percentage of sorts performed in 
PROMPT memory as opposed to sorts on disk. Setting the SORT_AREA_SIZE 
PROMPT in init.ora file to a higher value speeds index creation and
PROMPT sort/merge operations.

SELECT
    ROUND(
          (SUM(DECODE(name, 'sorts (memory)', value, 0))
        / (SUM(DECODE(name, 'sorts (memory)', value, 0))
        +  SUM(DECODE(name, 'sorts (disk)',   value, 0))))
        * 100,2
    ) "SORT EFFICIENCY (%)"
FROM 
    v$sysstat
;

PROMPT ************************************************************
PROMPT LOCKS 
PROMPT
PROMPT For getting info about locks the CATBLOCK.SQL must be run 
PROMPT before (as SYS) 
PROMPT
PROMPT * SYSTEM-WIDE LOCKS (all requests for locks or latches): 

SELECT 
    SUBSTR(username,1,12) "User", 
    SUBSTR(lock_type,1,18) "Lock Type", 
    SUBSTR(mode_held,1,18) "Mode Held" 
FROM 
    sys.dba_lock a, 
    v$session b 
WHERE 
    lock_type not in ('Media Recovery','Redo Thread') 
AND
    a.session_id = b.sid
; 

PROMPT * DDL LOCKS (These are usually triggers or other DDL): 

SELECT 
    SUBSTR(username,1,12) "User", 
    SUBSTR(owner,1,8) "Owner", 
    SUBSTR(name,1,15) "Name", 
    SUBSTR(a.type,1,20) "Type", 
    SUBSTR(mode_held,1,11) "Mode held" 
FROM
    sys.dba_ddl_locks a, 
    v$session b 
WHERE 
    a.session_id = b.sid
; 
 
PROMPT * DML LOCKS (These are table and row locks):

SELECT 
    SUBSTR(username,1,12) "User", 
    SUBSTR(owner,1,8) "Owner", 
    SUBSTR(name,1,20) "Name", 
    SUBSTR(mode_held,1,21) "Mode held" 
FROM
    sys.dba_dml_locks a, 
    v$session b 
WHERE
    a.session_id = b.sid
; 

PROMPT ************************************************************
PROMPT MAX LATCH CONTENTION
PROMPT
PROMPT Max Latch Contention is the largest % of latch contention 
PROMPT from key latches. Should be less 3%. If not, try decrease 
PROMPT LOG_SMALL_ENTRY_MAX_SIZE (in bytes) in init.ora.

SELECT 
    ROUND( 
        GREATEST(
        (SUM(DECODE(ln.name, 'cache buffers lru chain', misses, 0))
        / GREATEST(SUM(DECODE(ln.name, 'cache buffers lru chain', gets, 0)), 1)),
        (SUM(DECODE(ln.name, 'enqueues', misses, 0))
        / GREATEST(SUM(DECODE(ln.name, 'enqueues', gets, 0)), 1)),
        (SUM(DECODE(ln.name, 'redo allocation', misses, 0))
        / GREATEST(SUM(DECODE(ln.name, 'redo allocation', gets, 0)), 1)),
        (SUM(DECODE(ln.name, 'redo copy', misses, 0))
        / GREATEST(SUM(DECODE(ln.name, 'redo copy', gets, 0)), 1)))
        * 100, 2
    ) "MAX LATCH CONTENTION (%)"
FROM 
    v$latch l, 
    v$latchname ln
WHERE 
    l.latch# = ln.latch#
;

PROMPT ************************************************************
PROMPT REDO LOG BUFFER LATCHES 
PROMPT 
PROMPT If Miss Ratio or Immediate Miss Ratio > 1 then latch 
PROMPT contention exists, decrease LOG_SMALL_ENTRY_MAX_SIZE (in 
PROMPT bytes) in init.ora. You may increase LOG_SIMULTANEOUS_COPY 
PROMPT for the multiple-CPU computer also (default is the number of 
PROMPT CPUs).

COLUMN "Miss Ratio" FORMAT .99 
COLUMN "Immediate Miss Ratio" FORMAT .99 

SELECT 
    SUBSTR(l.name, 1, 30) name, 
    (misses / (gets + .001)) * 100 "Miss Ratio", 
    (immediate_misses / (immediate_gets + .001)) * 100  
        "Immediate Miss Ratio" 
FROM 
    v$latch l, 
    v$latchname ln 
WHERE 
    l.latch# = ln.latch# 
AND (
    (misses / (gets + .001)) * 100 > .2 
    OR 
    (immediate_misses/(immediate_gets+.001))*100 > .2
    ) 
ORDER BY 
    l.name
; 

PROMPT ************************************************************
PROMPT REDO LOG ALLOCATION LATCH CONTENTION 
PROMPT 
PROMPT The percentage of time that a process attempted to acquire 
PROMPT a redo log latch held by another process. Should be < 1%. 
PROMPT Rare on single-CPU systems. If not, decrease LOG_SMALL_ENTRY_MAX_SIZE 
PROMPT (in bytes) in init.ora. For multiple-CPU system you may 
PROMPT increase LOG_SIMULTANEOUS_COPIES up to 2*CPUs. Additionally, 
PROMPT try increasing the LOG_ENTRY_PREBUILD_THRESHOLD.

SELECT 
    ROUND(
        GREATEST(
        (SUM(DECODE(ln.name, 'redo copy', misses, 0))
        / GREATEST(SUM(DECODE(ln.name, 'redo copy', gets, 0)), 1)),
        (SUM(DECODE(ln.name, 'redo allocation', misses, 0))
        / GREATEST(SUM(DECODE(ln.name, 'redo allocation', gets, 0)), 1)),
        (SUM(DECODE(ln.name, 'redo copy', immediate_misses, 0))
        / GREATEST(SUM(DECODE(ln.name, 'redo copy', immediate_gets, 0))
        + SUM(DECODE(ln.name, 'redo copy', immediate_misses, 0)), 1)),
        (SUM(DECODE(ln.name, 'redo allocation', immediate_misses, 0))
        / GREATEST(SUM(DECODE(ln.name, 'redo allocation', immediate_gets, 0))
        + SUM(DECODE(ln.name, 'redo allocation', immediate_misses, 0)), 1)))
        * 100, 2
    ) "REDO ALLOC CONTENTION (%)"
FROM 
    v$latch l, v$latchname ln
WHERE 
    l.latch# = ln.latch#
;

PROMPT ************************************************************
PROMPT ROLLBACK SEGMENT CONTENTION 
PROMPT
PROMPT Total RS Contention is the percentage that a request for data
PROMPT resulted in a wait for a rollback segment. If > 1%, create
PROMPT more rollback segments.

SELECT
    ROUND(SUM(waits) / SUM(gets) * 100, 2) "TOTAL RS CONTENTION (%)"
FROM
    v$rollstat
;

PROMPT Detailed info regarding rolback segments contention: if any 
PROMPT Ratio is greater than 1% then more rollback segments are 
PROMPT needed. 
 
COLUMN "RATIO" FORMAT 99.99999 

SELECT 
    name, 
    waits, 
    gets, 
    ROUND (waits / gets * 100, 2) "RATIO (%)" 
FROM 
    v$rollstat a, 
    v$rollname b 
WHERE 
    a.usn = b.usn
; 

PROMPT If any COUNT below is > 1% of the total number of REQUESTS 
PROMPT FOR DATA then more rollback segments are needed. 

COLUMN count FORMAT 999,999,999 
SELECT 
    class, 
    count 
FROM 
    v$waitstat 
WHERE 
    class in (
        'free list',
        'system undo header',
        'system undo block', 
        'undo header',
        'undo block'
    ) 
GROUP BY 
    class,
    count
; 
 
COLUMN "REQUESTS FOR DATA" FORMAT 999,999,999 
SELECT 
    SUM(value) "REQUESTS FOR DATA" 
FROM 
    v$sysstat 
WHERE 
    name in (
        'db block gets', 
        'consistent gets'
    )
; 

PROMPT ************************************************************
PROMPT SESSION EVENT CONTENTION 
PROMPT 
PROMPT If AWERAGE_WAIT > 0 then contention exists. 
 
COLUMN total_waits FORMAT 999,999,999 
COLUMN total_timeouts FORMAT 999,999,999  
        
SELECT 
    SUBSTR(event,1,30) event, 
    total_waits, 
    total_timeouts, 
    average_wait 
FROM 
    v$session_event 
WHERE 
    average_wait > 0
; 
 
PROMPT ************************************************************
PROMPT QUEUE CONTENTION 
PROMPT 
PROMPT Average Wait (AVG WAIT) for queues should be near zero ... 

COLUMN totalq FORMAT 999,999,999 
COLUMN queued FORMAT 999,999,999 

SELECT 
    paddr, 
    type, 
    queued, 
    wait, 
    totalq, 
    DECODE(totalq, 0, 0, wait/totalq) "AVG WAIT" 
FROM 
    v$queue
; 
 
PROMPT ************************************************************
PROMPT MULTI_THREADED SERVER CONTENTION
PROMPT
PROMPT If Average Wait per REQUEST Queue > 1 then increase 
PROMPT MTS_MAX_SERVERS in init.ora.
 
SELECT 
    DECODE(
        totalq, 
        0, 'No Requests', 
        wait / totalq || ' hundredths of seconds'
    ) "AVG WAIT PER REQUEST QUEUE" 
FROM
    v$queue 
WHERE 
    type = 'COMMON'
; 

SELECT 
    COUNT(*) "Shared Server Processes" 
FROM 
    v$shared_server 
WHERE 
    status = 'QUIT'
; 
 
PROMPT If Average Wait per RESPONSE Queue increases, consider adding 
PROMPT dispatcher processes.

SELECT 
    network "Protocol",
    DECODE( 
        SUM(totalq), 
        0, 'No Responses', 
        (SUM(wait) / SUM(totalq)) || ' hundredths of seconds'
    ) "AVG WAIT PER RESPONSE QUEUE" 
FROM
    v$queue q, 
    v$dispatcher d 
WHERE 
    q.type = 'DISPATCHER' 
AND 
    q.paddr = d.paddr
GROUP BY
    network
; 
 
PROMPT If Total Busy Rate > 50%, then add dispetcher processes.
PROMPT The Total Busy Rate is the percentage of time the dispatcher 
PROMPT processes of each protocol are busy.

SELECT 
    network "Protocol", 
    ROUND(SUM(busy) / (SUM(busy) + SUM(idle)) * 100, 2) "TOTAL BUSY RATE" 
FROM 
    v$dispatcher
GROUP BY
    network
; 
  
PROMPT High-water mark for the multi-threaded server: 
 
SELECT * FROM v$mts; 
 
PROMPT ************************************************************
PROMPT INPUT/OUTPUT DISTRIBUTION
PROMPT
PROMPT File i/o should be evenly distributed across drives. 
PROMPT The total i/o for a single disk is sum of TOTAL I/O for all
PROMPT the database files on that disk. Determine the rate at which
PROMPT i/o occurs for each disk by dividing the total i/o by
PROMPT the interval of time over which the statistics were collected.
 
SELECT  
    SUBSTR(a.name, 1, 30) name,  
    b.phyrds, 
    b.phywrts,
    b.phyrds + b.phywrts "TOTAL I/O" 
FROM 
    v$datafile a, 
    v$filestat b 
WHERE 
    a.file# = b.file#
ORDER BY 
    b.phyrds + b.phywrts DESC
; 

PROMPT For minimizing the number of I/Os try to increase 
PROMPT the initialization parameter DB_FILE_MULTIBLOCK_READ. 
PROMPT  
PROMPT Next query shows I/O distribution on a per-tablespace 
PROMPT basis.

SELECT 
    ts.name Tablespace,
    SUM(x.phyrds) Reads,
    SUM(x.phywrts) Writes,
    SUM(x.phyrds) + SUM(x.phywrts) "TOTAL I/O",
    SUM(x.phyblkrd) + SUM(x.phyblkwrt) Blocks
FROM
    v$filestat x,
    ts$ ts,
    v$datafile i,
    file$ f    
WHERE
    i.file# = f.file# AND
    ts.ts# = f.ts# AND
    x.file# = f.file#
GROUP BY
    ts.name
ORDER BY
    ts.name
;

PROMPT ************************************************************
PROMPT GENERAL SYSTEM STATISTICS

SELECT 
    SUBSTR(name, 1, 55) system_statistic, 
    value 
FROM 
    v$sysstat 
ORDER BY 
    name
;

 
PROMPT ************************************************************

@_END
