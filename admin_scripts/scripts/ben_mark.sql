REM
REM  Benchmark Performance Statistics : Release 1
REM  
REM  Author:
REM     Mark Gurry  "Oracle Performance Tuning"
REM  
REM  Description:
REM     This script is an early release of a total database tuning 
REM     script. 
REM  
REM  
REM  Hints:
REM     It is best to run this script as SYS because some of the 
REM  	tables/views may not be accessible to other users. Most
REM  	of the scripts will run successfully as other DBA users
REM  	if you do not have access to the SYS account. You must
REM  	run the script in SQL*Plus NOT SQL*DBA. 
REM  
REM  	You are required to run $ORACLE_HOME/rdbms/admin/catparr.sql
REM  	prior to running this script, to receive buffer cache
REM  	information. You only need to run the catparr script once, 
REM  	and the views that it creates will remain in place. 
REM  
REM  Inputs:
REM     The script will request two pieces of information from you.
REM  	Both are being asked to avoid lengthy printouts. Note that
REM  	even if you do no answer Y or y, the output results will be
REM  	in the region of 15 pages.
REM  
REM  	(1) Do you request all of the INIT.ORA parameters listed 
REM  	    Print_init_ora_parameters_y_n  To have them listed,
REM  	    enter Y or y.
REM  
REM  	(2) Do you wish to look inside the buffer cache to receive
REM  	    a full list of objects. The size of this output and the
REM  	    length of time that it takes to run will be directly 
REM  	    proportional to the DB_BLOCK_BUFFERS setting. The larger
REM  	    the setting, the longer the run will take and the larger
REM  	    the size of the output. 
REM  

@_BEGIN

PROMPT 
PROMPT Before we start, it is always nice to work out the versions of the 
PROMPT the database server. This may prove useful if we need to compare this
PROMPT output against a future release of Oracle.
PROMPT 

SELECT * FROM v$version                     
/

@_TITLE 'INIT.ORA Parameters'
COLUMN name FORMAT A46
COLUMN value FORMAT A32
		   
SELECT name, value 
FROM v$parameter
WHERE '&&Print_init_ora_parameters_y_n' in ('y','Y')
ORDER BY name;

COLUMN value FORMAT 999,999,999,999

PROMPT 
PROMPT The following listing gives details of the Shared Global Area 
PROMPT breakdown in memory. The more significant information is the 
PROMPT reading for "free memory", which indicates that the SHARED_POOL_SIZE
PROMPT INIT.ORA parameter may be reduced if the free memory is excessive.
PROMPT If it is low, you should NOT be decreasing the SHARED_POOL_SIZE.
PROMPT Be careful however, because Oracle tends to maintain some free 
PROMPT memory even when the buffer cache is flooded with activity and
PROMPT should be made larger.
PROMPT 
PROMPT Other figures that are useful are the  size of the buffer cache
PROMPT "db_block_buffers" which is usually required to be at least 20 Meg
PROMPT for optimum performance, the sql_area, which is where all of the 
PROMPT shared SQL is placed, the dictionary cache, which is where Oracle's
PROMPT dictionary is placed, and the "log buffer" which is where all 
PROMPT changes are written prior to writing to your redo logs. 
PROMPT 
PROMPT The log buffer should typically be at least 32078 or larger. 
PROMPT The "shared_sql" and "dictionary_cache" sizes are affected by the 
PROMPT size that you set the SHARED_POOL_SIZE INIT.ORA parameter to. 
PROMPT Unfortunately, the dictionary cache is tuned automatically and not 
PROMPT very well by the kernel. Most sites operate most effeciently with
PROMPT a shared pool size of at least 30000000.               
PROMPT 

@_TITLE 'SGA Statistic Listing'

SELECT * FROM v$sgastat
ORDER BY name;

@_TITLE 'CUMULATIVE HIT RATIO'

SELECT 
    SUM(DECODE(name, 'consistent gets', value, 0)) "Consist Gets",
    SUM(DECODE(name, 'db block gets', value, 0)) "DB Block Gets",
    SUM(DECODE(name, 'physical reads', value, 0)) "Physical Reads",
    (SUM(DECODE(name, 'consistent gets', value, 0)) +
    SUM(DECODE(name, 'db block gets', value, 0)) -
    SUM(DECODE(name, 'physical reads', value, 0))) /
    (SUM(DECODE(name, 'consistent gets', value, 0)) +
    SUM(DECODE(name, 'db block gets', value, 0))) * 100 "Hit Ratio" 
FROM 
    v$sysstat
;

PROMPT 
PROMPT The following output is of Oracle's dictionary cache the is
PROMPT stored in memory, in the System Global Area. The dictionary is
PROMPT tuned automatically by Oracle. The three columns displayed are the
PROMPT dictionary cache parameter, the count that Oracle has set the parameter
PROMPT to and the number of times that Oracle has had to reload the dictionary
PROMPT information from disk. When Oracle is first started and objects are
PROMPT being accessed for the first time, a miss occurs because a disk read 
PROMPT has been required to access the information. Ideally from then on,
PROMPT there will be no more misses because the dictionary info will be
PROMPT nicely placed in memory. Unfortunately this is not the case. Oracle's
PROMPT self tuning mechainism does not appear to work very well.
PROMPT 
PROMPT In the following query, the ideal output would be to see the 
PROMPT the getmisses less than or equal to the count, which implies that
PROMPT the parameter has been set sufficiently high enough to fit all of
PROMPT the dictionary items into memory without having to flush them out
PROMPT and then reload them.
PROMPT 
PROMPT If you are getting deplorable figures, i.e. the getmisses considerably
PROMPT higher than the count, increase the SHARED_POOL_SIZE. If this has no
PROMPT effect, then join the club requesting that Oracle re-introduce the ability
PROMPT for DBAs to tune the dictionary cache.
PROMPT 

@_TITLE 'Dictionary Cache (Part of Shared Buffer Pool)'

SELECT 
    parameter, 
    count, 
    getmisses,
    DECODE(SIGN(getmisses - count), -1, ' ', 0, ' ', 1, '*') "!"
FROM 
    v$rowcache
ORDER BY
    parameter
;

PROMPT 
PROMPT The following script shows the spread of disk I/O's. Ideally the 
PROMPT disk I/O's should be even across disks. If the disk I/O on one
PROMPT of the disks is too high, consider moving one of the datafiles on
PROMPT that disk to another disk. If you are using raw devices, it is
PROMPT handy to make the raw devices consistent sizes for this purpose.
PROMPT If you can't move one of the datafiles, consider moving objects
PROMPT into tablespaces on different disks.
PROMPT 
PROMPT If there is a large amount of activity on one of the disks, there
PROMPT is often an untuned query causing the damage. Be aware of which
PROMPT table is causing the problems. The V$SQLAREA table has a column
PROMPT called disk reads as well as the SQL statement that was performed.
PROMPT If you select all statements with > 1000 disk reads, and order it
PROMPT by disk reads desc, it is often an indicator of the problem query.
PROMPT 
PROMPT See the selection from the table later in this script.
PROMPT 
PROMPT One trick that is often done is to alternate rollbacks one disk to
PROMPT the next into alternate tablespaces, for example, rollback1 will be
PROMPT created on the rollback_disk1 tablespace, rollback2 on  rollback_disk2
PROMPT tablespace, rollback3 on  rollback_disk1 tablespace, rollback4 on
PROMPT rollback_disk2 tablespace and so on. Of course, you must have the
PROMPT rollback_disk1 tablespace on a separate disk drive to rollback_disk2.
PROMPT 

@_HIDE
DROP TABLE temp$tot_read_writes;

CREATE TABLE temp$tot_read_writes AS 
    SELECT SUM(phyrds) phys_reads, sum(phywrts) phys_wrts
    FROM v$filestat;

@_SET
@_TITLE 'Disk I/O by Datafile'

COLUMN name FORMAT A34;
COLUMN phyrds FORMAT 999,999,999;
COLUMN phywrts FORMAT 999,999,999;
COLUMN read_pct FORMAT 999.99;         
COLUMN write_pct FORMAT 999.99;        
 
SELECT name, phyrds, phyrds * 100 / trw.phys_reads read_pct, 
    phywrts,  phywrts * 100 / trw.phys_wrts write_pct
FROM temp$tot_read_writes trw, v$datafile df, v$filestat fs
WHERE df.file# = fs.file# 
ORDER BY phyrds DESC;

@_HIDE
DROP TABLE temp$tot_read_writes;
@_SET

PROMPT 
PROMPT The next group of figures are the those for table accesses.
PROMPT 
PROMPT The "table fetch row continued rows" have been accessed and the row has 
PROMPT either been chained or migrated. Both situations result from part of
PROMPT a row has been forced into another block. The distinction is for
PROMPT chained rows, a block is physically to large to fit in one physical 
PROMPT block. 
PROMPT 
PROMPT In these cases, you should look at increasing the db_block_size
PROMPT next time you re-build your database, and for other environments, e.g.
PROMPT when you move your application into production. Migrated rows are rows
PROMPT that have been expanded, and can no longer fit into the same block. In these
PROMPT cases, the index entries will point to the original block address, but the
PROMPT row will be moved to a new block. The end result is that FULL TABLE SCANS
PROMPT will run no slower, because the blocks are read in sequence regardless of
PROMPT where the rows are. Index selection of the row will cause some degradation
PROMPT to response times, because it continually has to read an additional block.
PROMPT To repair the migration problem, you need to increase the PCTFREE on the
PROMPT offending table.
PROMPT 
PROMPT The other values include "table scans (long tables)" which is a scan 
PROMPT of a table that has > 5 database blocks and table scans (short tables)
PROMPT which is a count of Full Table Scans with 5 or less blocks. These values
PROMPT are for Full Table Scans only. Any Full Table Scan of a long table can
PROMPT be potentially crippling to your application's performance. If the number
PROMPT of long table scans is significant, there is a strong possibility that
PROMPT SQL statements in your application  need tuning or indexes need to be added.
PROMPT 
PROMPT To get an appreciation of how many rows and blocks are being accessed on
PROMPT average for the long full table scans:                           
PROMPT 
PROMPT Average Long Table Scan Blocks = 
PROMPT table scan blocks gotten - (short table scans * 5) / long table scans
PROMPT 
PROMPT Average Long Table Scan Rows = 
PROMPT table scan rows gotten - (short table scans * 5) / long table scans
PROMPT 
PROMPT The output also includes values for "table scan (direct read)" which
PROMPT are those reads that have bypassed the buffer cache, table scans 
PROMPT (rowid ranges) and table scans (cache partitions).
PROMPT 

@_TITLE "TABLE PROCESSING STATISTICS"
SELECT name, value 
FROM v$sysstat
WHERE name LIKE '%table %'
ORDER BY name
/

@_HIDE
DROP TABLE temp$full_table_scans;

CREATE TABLE temp$full_table_scans AS
    SELECT 
        ss.username || '(' || se.sid || ') ' "User Process", 
        SUM(DECODE(name, 'table scans (short tables)', value)) "Short Scans",
        SUM(DECODE(name, 'table scans (long tables)', value)) "Long Scans",
        SUM(DECODE(name, 'table scan rows gotten', value)) "Rows Retreived"
    FROM 
        v$session ss, 
        v$sesstat se, 
        v$statname sn
    WHERE 
        se.statistic# = sn.statistic#
        AND (name like '%table scans (short tables)%'
             OR name  like '%table scans (long tables)%'
             OR name like '%table scan rows gotten%')
        AND se.sid = ss.sid
        AND ss.username IS NOT NULL
    GROUP BY 
        ss.username || '(' || se.sid || ') '
/

@_SET
@_TITLE 'Table Access Activity By User'
COLUMN  "User Process"     FORMAT A20;  
COLUMN  "Long Scans"       FORMAT 999,999,999;   
COLUMN  "Short Scans"      FORMAT 999,999,999;   
COLUMN  "Rows Retreived"   FORMAT 999,999,999;   
COLUMN  "Average Long Scan Length" FORMAT 999,999,999;   

SELECT 
    "User Process", 
    "Long Scans", 
    "Short Scans", 
    "Rows Retreived"
FROM 
    temp$full_table_scans 
ORDER BY 
    "Long Scans" DESC
; 

@_TITLE 'Average Scan Length of Full Table Scans by User'

select 
    "User Process", 
    ("Rows Retreived" - ("Short Scans" * 5)) 
        / ( "Long Scans" ) "Average Long Scan Length"
FROM 
    temp$full_table_scans 
WHERE 
    "Long Scans" != 0
ORDER BY 
    "Long Scans" DESC
; 

@_HIDE
DROP TABLE temp$full_table_scans;
@_SET

PROMPT
PROMPT The ideal is to have as much sorting in memory as possible. The
PROMPT amount of memory available for sorting in memory is set by assigning 
PROMPT a value to the INIT.ORA parameter SORT_AREA_SIZE. If there is a large 
PROMPT amount of sorting being done on disk, consider enlarging the 
PROMPT SORT_AREA_SIZE. Be aware that this parameter applies to all users
PROMPT and there must be sufficient memory to adjust the parameter upwards.
PROMPT 
PROMPT Some sorts to disk are simply too large to be done in memory. In these
PROMPT cases, make sure that the DEFAULT INITIAL and NEXT extents are sized
PROMPT sufficiently large enough to avoid unnecessary dynamic extension.
PROMPT     

@_TITLE 'Checking any Disk Sorts'

SELECT name, value 
FROM v$sysstat
WHERE name LIKE 'sort%';

PROMPT 
PROMPT The following query indicates the amount of rollbacks performed
PROMPT on the transaction tables. 
PROMPT 
PROMPT (i)  'transaction tables consistent reads - undo records applied'
PROMPT is the total # of undo records applied to rollback transaction
PROMPT tables only. It should be < 10% of the total number of consistent 
PROMPT changes.
PROMPT 
PROMPT (ii) 'transaction tables consistent read rollbacks'
PROMPT is the number of times the transaction tables were rolled back.
PROMPT It should be less than 0.1 % of the value of consistent gets.
PROMPT 
PROMPT If either of these scenarios occur, consider creating more rollback
PROMPT segments, or a greater number of extents in each rolback segment. A
PROMPT rollback segment equates to a transaction table and an extent is like
PROMPT a transaction slot in the table. 
PROMPT 
PROMPT Another interesting approach that Oracle mentions is to do a 
PROMPT SELECT COUNT(*) FROM TNAME(s); where the TNAMES are the tables
PROMPT that the blocks that have been modified and committed occur in.
PROMPT This marks the transactions as committed and later queries do not
PROMPT have to find the status of the transactions in the transaction tables
PROMPT to determine the status of the transactions.
PROMPT 
   
@_TITLE 'Amount of Rollbacks on Transaction Tables'
COLUMN name FORMAT A62 

SELECT name, value      
FROM v$sysstat
WHERE name IN (
    'consistent gets',
    'consistent changes',
    'transaction tables consistent reads - undo records applied',
    'transaction tables consistent read rollbacks'
    );

SET HEADING OFF
SELECT 
    'Tran Table Consistent Read Rollbacks > 1% of Consistent Gets' nl,
    'Action: Create more Rollback Segments'
FROM 
    v$sysstat
WHERE 
    DECODE (name, 'transaction tables consistent read rollbacks', value) * 100 /
        DECODE (name, 'consistent gets', value) > 0.1
    AND name IN (
        'transaction tables consistent read rollbacks',
        'consistent gets')
    AND value > 0
;   
 
SELECT 
    'Undo Records Applied > 10% of Consistent Changes' nl,
    'Action: Create more Rollback Segments'
FROM 
    v$sysstat
WHERE 
    DECODE (name, 'transaction tables consistent reads - undo records applied', value) * 100 /
        DECODE (name, 'consistent changes', value) > 10  
    AND name IN (
        'transaction tables consistent reads - undo records applied',
        'consistent changes')
    AND value > 0
;
SET HEADING ON
  
PROMPT 
PROMPT The last two values returned in the following query are the number
PROMPT of times data blocks have been rolled back. If the number of rollbacks
PROMPT is continually growing, it can be due to inappropriate work practice.
PROMPT Try breaking long running queries into shorter queries, or find another
PROMPT method of querying hot blocks in tables that are continually changing. 
PROMPT 

@_TITLE "ROLLBACKS STATISTICS"
SELECT name, value
FROM v$sysstat
WHERE name IN (
     'data blocks consistent reads - undo records applied',
     'no work - consistent read gets',   
     'cleanouts only - consistent read gets',
     'rollbacks only - consistent read gets',
     'cleanouts and rollbacks - consistent read gets')
;

PROMPT 
PROMPT Each rollback segment has a transaction table that controls the 
PROMPT transactions accessing the rollback segment. Oracle documentation
PROMPT says that the transaction table has approximately 30 slots in the 
PROMPT table if your database has a 2k block size. The following query
PROMPT lists the number of waits on a slot in the transaction tables. The
PROMPT ideal is to have the waits zero, but in the real world this is not 
PROMPT always achievable. The should be as close to zero as possible.
PROMPT At the very worst, the ratio of gets to waits should be around 99%.
PROMPT 

@_TITLE "TRANSACTION TABLES ACTIVITY"
SELECT 
    usn "Rollback Table", 
    Gets, 
    Waits , 
    xacts "Active Transactions"
FROM 
    v$rollstat
;

PROMPT 
PROMPT It is important that rollback segments do not extend very often. 
PROMPT Dynamic extension is particularly  damaging to performance, because
PROMPT each extent used (or freed) is written to disk immediately. See the 
PROMPT uet$ and fet$ system tables. 
PROMPT 
PROMPT Some sites have a large amount of performance degradation when
PROMPT the optimal value is set, because the rollback is continually 
PROMPT shrinking and extending. This situation has been improved to 
PROMPT make the SMON less active where the PCTINCREASE is set to 0. 
PROMPT 
PROMPT Note: in this case, free extents will not be coalesced. When 
PROMPT a rollback throws extents after it has shrunk back, it will hopefully
PROMPT find an extent of the correct size. If you would like the coalescing
PROMPT to continue, set the PCTINCREASE on the tablespace to 1. 
PROMPT 
PROMPT We usually recommend NOT to use the OPTIMAL setting. 
PROMPT 
PROMPT The listing below provides figures on how many times each rollback
PROMPT segment has had to extend and shrink.
PROMPT 

@_TITLE "ROLLBACK SEGMENTS RESIZING STATISTIC"
SELECT usn, extends, shrinks, hwmsize, aveshrink 
FROM v$rollstat;

PROMPT 
PROMPT The following query shows you the amount of overall changes that are 
PROMPT made to data blocks in the database 'db block changes'. The second
PROMPT value returned is the number of blocks that have been rolled back
PROMPT rollback changes - undo records applied' and the third value is the
PROMPT number of rollback transactions 'transaction rollbacks'.
PROMPT 
PROMPT When a rollback takes place, it can hold many resources until the 
PROMPT rollback is complete. If the rollbacks are significant in size, i.e.
PROMPT the cause of the rollbacks should be investigated. A way to check
PROMPT this is to check 'rollback changes - undo records applied' /
PROMPT 'transaction rollbacks'.
PROMPT 
PROMPT If the overall percentage of rows rolled back as compared to those 
PROMPT changes is significant (> .5%), you should question why are so many
PROMPT rows being rolled back. The causes could be many, including a network
PROMPT failure where sessions are continually being lost. Consider introducing
PROMPT SAVEPOINTS where appropriate or using shorter transactions to have 
PROMPT fewer rows to rollback (i.e. more frequent commits and less rows being
PROMPT processed).
PROMPT 

@_TITLE 'Get all V$SYSSTAT'
COLUMN name FORMAT A47
COLUMN value FORMAT 999999999

SELECT 
    statistic#,
    class,      
    name,
    value 
FROM v$sysstat
ORDER BY class, name;

PROMPT 
PROMPT The following query displays information on wait contention for 
PROMPT an Oracle object. The two figures of particular importance are
PROMPT the 'data block' and the 'undo header' waits. The undo header 
PROMPT indicates a wait for rollback segment headers which can be solved by 
PROMPT adding rollback segments. 
PROMPT 
PROMPT The data block wait is a little harder to find the cause of and 
PROMPT a little harder to fix. Basically, transactions are contending for
PROMPT hot data blocks, because it is being held by another transaction, 
PROMPT or contending for shared resources within the block. e.g. transaction
PROMPT entries (set by the INITRANS parameter) and rows. The INITRANS  
PROMPT storage parameter sets the number of transaction slots set aside 
PROMPT within each table/index. The default INITRANS is 1. If more than
PROMPT one transaction is waiting to access a block, a second transaction
PROMPT slot will have to be created. Each transaction slot uses 23 bytes.
PROMPT 
PROMPT The ideal count on the data block waits is 0.   This is usually not
PROMPT achievable in the real world, because the storage overhead of increasing
PROMPT the INITRANS is usually not justified given the large amount of
PROMPT storage overhead that it will introduce. Data block contention can cause
PROMPT problems and enlarging INITRANS can improve performance, so don't
PROMPT dismiss the idea of enlarging INITRANS immediately.   Potential 
PROMPT performance improvements CAN be significant.
PROMPT 
PROMPT Identifying the blocks that are experiencing contention is quite
PROMPT difficult to catch. Your best chance is to examine the output from the
PROMPT query from the V$SESSION_WAIT table below. You may consider increasing
PROMPT the PCTFREE in the table to have fewer rows per block, or make a design
PROMPT change to your application to have fewer transactions accessing the same
PROMPT block. 
PROMPT 

@_TITLE 'Get All Waits' 

COLUMN count FORMAT 9999999;
SELECT class, count 
FROM v$waitstat
ORDER BY class;

@_TITLE 'Sessions experiencing block level contention'

SELECT ss.username, sw.p1 "File", sw.p2  "Block"
FROM v$session_wait sw, v$session ss
WHERE event = 'buffer busy waits'
AND ss.sid = sw.sid;

@_TITLE 'The Object that has Experienced Contention'

COLUMN "Owner" FORMAT A16
COLUMN "Segment Name" FORMAT A30

SELECT 
    owner "Owner" , 
    segment_name "Segment Name"
FROM  
    dba_extents
WHERE 
    (file_id, block_id) in (
        SELECT file_id, block_id
        FROM dba_extents, v$session_wait vw 
        WHERE file_id = vw.p1    
        AND (p1, p2) IN (
            SELECT p1, p2      
            FROM v$session_wait
            WHERE event = 'buffer busy waits'
            )
        AND block_id = (
            SELECT MAX(block_id) 
            FROM dba_extents
            WHERE block_id < vw.p2
            )
        )
/

PROMPT 
PROMPT The following query indicates a transaction waiting for resources
PROMPT within a block currently held by another transaction. This can 
PROMPT be caused by having to throw another transaction slot in the
PROMPT block. 
PROMPT 
PROMPT In extreme cases, throwing many transaction slots into a 
PROMPT block can cause the migration of a row, which will have a similar 
PROMPT effect to chaining, when the block is accessed via an index, i.e.
PROMPT two blocks may have to be read to retrieve a row. Remember that each
PROMPT transaction slot uses 23 bytes. The smaller the DB_BLOCK_SIZE the
PROMPT greater the possibility of row migration. The other cause of the   
PROMPT locks in the following query is that a row within the block are 
PROMPT sought  after by two separate transactions. This problem is usually
PROMPT only fixable through an application change, where you postpone the
PROMPT changes to the rows until the last possible moment in the transaction. 
PROMPT 

@_TITLE 'Transactions Experiencing Lock Contention'

SELECT * 
FROM v$lock 
WHERE type = 'TX';


PROMPT 
PROMPT The following query scans through the buffer cache and counts the number
PROMPT of buffers in the various states. The three main states are CUR which is
PROMPT blocks read but not dirtied, CR which are blocks that have been dirtied 
PROMPT and are remaining in cache with the intention of supplying the new values 
PROMPT to queries about to start up. FREE indicates buffers that are usable to 
PROMPT place new data being read into the buffer cache. You occasionally get 
PROMPT buffers in a status of READ which are those buffers currently being read 
PROMPT into the buffer cache. 
PROMPT 
PROMPT The major information from the query is if the FREE count is high, say
PROMPT > 50% of overall buffers, you may consider decreasing the DB_BLOCK_BUFFERS
PROMPT parameter. Note however, that Oracle attempts to maintain a free count > 
PROMPT 0, so consistently having free buffers does not automatically imply that
PROMPT you should have lower the parameter DB_BLOCK_BUFFERS.
PROMPT 
PROMPT To create the view v$bh, which is used by this script, you must run    
PROMPT the script $ORACLE_HOME/rdbms/admin/catparr.sql
PROMPT 

@_TITLE 'Current Buffer Cache Usage'

SELECT status, count(*) 
FROM v$bh 
GROUP BY status;

PROMPT 
PROMPT Remember that the buffer cache stores Tables, Indexes, Dictionary Tables,
PROMPT Sort Temporary Tables and Rollback Segments. Oracle 7.1, 7.2 and 7.3    
PROMPT of Oracle introduce options to bypass the buffer cache for some of these 
PROMPT operations.            
PROMPT 
PROMPT See the 7.2 parameter SORT_DIRECT_TRUE which bypasses the buffer cache and
PROMPT allows sorts to run as much as 3 times as fast.
PROMPT 
PROMPT In 7.1.6 parallel table scans can bypass the buffer cache if you set 
PROMPT compatible=7.1.6
PROMPT 
PROMPT In 7.2 Oracle turns off logging (not strictly buffer cache) if you use the
PROMPT UNRECOVERABLE option. When building an index, you can bypass writing to
PROMPT redo logs by setting this parameter. The direct load path is used also to 
PROMPT bypass the buffer cache. One interesting point is that INRECOVERABLE is
PROMPT the default when Archiving is not enabled.	
PROMPT 

@_TITLE 'What is Currently Being Stored in the Buffer Cache'

SELECT kind, name, status, count(*) 
FROM v$cache
WHERE SUBSTR('&Look_inside_Buffer_Cache_y_n', 1, 1) in ('y','Y')
GROUP BY kind, name, status;

PROMPT 
PROMPT When you enlarge the DB_BLOCK_BUFFERS, if you see decreases in the 
PROMPT values returned in the following query, it is almost always associated
PROMPT with a performance improvement. Keep in mind that there are two aspects to 
PROMPT buffer cache tuning (i) having data in memory is up to several thousand
PROMPT times faster than finding it on disk and (ii) when Oracle is reading data
PROMPT into memory and is forced to clear buffers quickly because buffer cache
PROMPT is too small, it often does so in "panic mode" which can have a harmful
PROMPT effect on performance.
PROMPT 
PROMPT This means that the HIT RATIO alone tells only part of the story.
PROMPT 
PROMPT The following figures tell us how much panicking the DBWR has had to do.
PROMPT It is best if the cache is sufficiently large enough to clean blocks out
PROMPT using the normal mechanisms rather than in panic mode.
PROMPT 
PROMPT NOTE: The DBWR process writes to disk under the following circumstances
PROMPT 
PROMPT (i)   When a process dirties a buffer and the number of dirty buffers in the
PROMPT buffer cache reaches the count set by the parameter DB_BLOCK_WRITE_BATCH.
PROMPT If this is the case 50% of the dirty buffers are written to disk.
PROMPT 
PROMPT (ii)  When a process searches DB_BLOCK_MAX_SCAN_CNT buffers in the list      
PROMPT without finding a free buffer. If this is the case it signals the 
PROMPT DBWR to write to make way for free buffers.
PROMPT 
PROMPT (iii) Every 3 seconds (when a timeout occurs).
PROMPT 
PROMPT (iv)  When a checkpoint occurs the LGWR instructs the DBWR to write.
PROMPT 
PROMPT The last situation is interesting because it implies that badly tuned 
PROMPT checkpoints will potentially cause DBWR problems.
PROMPT 
PROMPT The rows returned in the query below indicate the following:
PROMPT 
PROMPT DBWR Checkpoints: is the number of times that checkpoints were sent to the
PROMPT database writer process DBWR. The log writer process hands a list of modified 
PROMPT blocks that are to be written to disk. The "dirty" buffers to be written 
PROMPT are pinned and the DBWR commences writing the data out to the database.
PROMPT It is usually best to keep the DBWR checkpoints to a minimum, although 
PROMPT if there are too many dirty blocks to write out to disk at the one time
PROMPT due to a "lazy" DBWR, there may be a harmful effect on response times for
PROMPT the duration of the write.  See the parameters LOG_CHECKPOINT_INTERVAL and
PROMPT LOG_CHECKPOINT_TIMEOUT which have a direct effect on the regularity of 
PROMPT checkpoints. The size of your red logs  can also have an effect on the
PROMPT number of checkpoints if the LOG_CHECKPOINT_INTERVAL is set to a size 
PROMPT larger than your redo logs and the LOG_CHECKPOINT_TIMEOUT is longer than
PROMPT the time it takes fill a redo log or it has not been set. 
PROMPT 
PROMPT DBWR timeouts: the # times that the DBWR looked for dirty blocks to
PROMPT write to the database. Timeouts occur every 3 seconds if the DBWR is idle.           
PROMPT  
PROMPT DBWR make free requests: is the number of messages recieved requesting the
PROMPT database writer process to make the buffers free. This value is a key 
PROMPT indicator as to how effectively your DB_BLOCK_BUFFERS parameter is tuned.
PROMPT If you increase DB_BLOCK_BUFFERS and this value decreases markedly, there
PROMPT is a very high likelihood that the DB_BLOCK_BUFFERS was set too low.
PROMPT 
PROMPT DBWR free buffers found: is the number of buffers that the DBWR found 
PROMPT on the lru chain that were already clean. You can divide this value by 
PROMPT the DBWR make free requests to obtain the number of buffers that were 
PROMPT found which were free and clean (i.e. did NOT have to be written to disk).
PROMPT 
PROMPT DBWR lru scans: the number of times that the database writer scans the lru
PROMPT for more buffers to write. The scan can be invoked either by a make free
PROMPT request or by a checkpoint. 
PROMPT 
PROMPT DBWR summed scan depth: can be divided by DBWR lru scans to determine the
PROMPT length of the scans through the buffer cache. This is NOT the number of   
PROMPT buffers scanned. if the write batch is filled and a write takes place
PROMPT to disk, the scan depth halts. 
PROMPT 
PROMPT DBWR buffers scanned: is the total  number of buffers scanned when looking 
PROMPT for dirty buffers to write to disk and create free space. The count 
PROMPT includes both dirty and clean buffers. It does NOT halt like the 
PROMPT DBWR summed scan depth.
PROMPT 

@_TITLE 'The Amount of Times Buffers Have Had to Be Cleaned Out'

SELECT name, value 
FROM v$sysstat
WHERE name LIKE 'DBW%';

@_TITLE 'The Average Length of the Write Request Queue'

COLUMN "Write Request Length" FORMAT 999,999.99

SELECT  
    DECODE (name, 'summed dirty queue length', value)
    /
    DECODE (name, 'write requests', value) "Write Request Length"
FROM 
    v$sysstat
WHERE  
    name IN (
        'summed dirty queue length',
        'write requests'
    )
    AND value > 0
/

PROMPT 
PROMPT The information listed in the next query is the count for "Dirty Buffers
PROMPT Inspected". This figure indicates that the DBWR process can't keep up 
PROMPT through natural atrition and a dirty buffer has been aged out through
PROMPT the LRU queue, when a user process has been looking for a free buffer
PROMPT to use. This value should ideally be zero. The value is probably THE key
PROMPT indicator of the DB_BLOCK_BUFFERS init.ora parameter being set too small,
PROMPT particularly if you enlarge the DB_BLOCK_BUFFERS parameter and the value
PROMPT reduces after each decrease. 
PROMPT 
PROMPT Also included in the output, is the value for "Free Buffers Inspected".
PROMPT This figure indicates the number of times a user process has scanned the 
PROMPT LRU list for free buffers. A high value would indicate that there are too 
PROMPT many dirty blocks on the LRU list and the user process had to stop because
PROMPT the dirty queue was at its threshold. 
PROMPT 

COLUMN "Dirty Buffers" FORMAT 999,999,999;
COLUMN "Free Buffers Inspected" FORMAT 999,999,999;

@_TITLE 'Lazy DBWR Indicators - Buffers Inspected'

SELECT  
    DECODE (name, 'dirty buffers inspected', value) "Dirty Buffers",
    DECODE (name, 'free buffer inspected', value) "Free Buffers Inspected"
FROM 
    v$sysstat
WHERE  
    name IN ( 
        'dirty buffers inspected',
        'free buffer inspected'
    )
    AND value > 0
/

PROMPT 
PROMPT The following query breaks down hit ratios by user. The lower the hit ratio
PROMPT the more disk reads that have to be performed to find the data that the user 
PROMPT is requesting. If a user is getting a low hit ratio (say < 60%), it is often
PROMPT caused because  the user not using indexes effectively or an absence of 
PROMPT indexes. It can sometimes be quite OK to get a low hit ratio if the user
PROMPT is accessing data that has not been accessed before and cannot be shared
PROMPT amongst users. Note: OLTP applications ideally have a hit ratio in the mid
PROMPT to high 90s. 
PROMPT 
PROMPT The second query lists the tables that the user processes with a hit ratio
PROMPT less than 60% were accessing. Check the tables to ensure that there are no
PROMPT missing indexes.
PROMPT 

@_TITLE 'User Hit Ratios'

COLUMN "Hit Ratio" FORMAT 999.99
COLUMN "User Session" FORMAT A15;

SELECT 
    se.username || '(' || se.sid || ')' "User Session",
    SUM(DECODE(name, 'consistent gets', value, 0)) "Consis Gets",
        SUM(DECODE(name, 'db block gets', value, 0)) "DB Blk Gets",
        SUM(DECODE(name, 'physical reads', value, 0)) "Phys Reads",
       (SUM(DECODE(name, 'consistent gets', value, 0)) +
        SUM(DECODE(name, 'db block gets', value, 0)) -
        SUM(DECODE(name, 'physical reads', value, 0))) /
       (SUM(DECODE(name, 'consistent gets',value, 0)) +
        SUM(DECODE(name, 'db block gets',value, 0)) ) * 100 "Hit Ratio" 
FROM  
    v$sesstat ss, v$statname sn, v$session se
WHERE ss.sid    = se.sid
    AND sn.statistic# = ss.statistic#
    AND value != 0
    AND sn.name IN (
        'db block gets', 
        'consistent gets', 
        'physical reads'
    )
GROUP BY 
    se.username, se.sid
;

@_CLEAR
@_TITLE 'List Statements in Shared Pool by Disk Reads'
SET HEADING OFF
COLUMN "Response" FORMAT 999,999.99
COLUMN sql_text FORMAT A79 WORD_WRAP
COLUMN nl NEWLINE
SELECT 
    ' ' nl, 
    sql_text nl,
    ' ' nl, 
    '>>>>>>>>>> EXECUTIONS = ' || executions nl,
    '>>>>>>>>>> EXPECTED RESPONSE TIME IN SECONDS = ', 
    disk_reads / DECODE(executions, 0, 1, executions) / 50 "Response"  
FROM 
    v$sqlarea
WHERE  
    disk_reads / DECODE(executions, 0, 1, executions) / 50 > 10 
ORDER BY 
    executions DESC
;

@_TITLE 'List Statements in Shared Pool with the Buffer Scans'   
SET HEADING OFF
select 
    ' ' nl, 
    sql_text nl, 
    ' ' nl,
    '>>>>>>>>>> EXECUTIONS = ' || executions nl,
    '>>>>>>>>>> EXPECTED RESPONSE TIME IN SECONDS = ', 
    buffer_gets / DECODE(executions, 0, 1, executions) / 500 "Response"  
FROM 
    v$sqlarea
WHERE  
    buffer_gets / decode(executions, 0, 1, executions) / 500 > 10 
ORDER BY 
    executions DESC
;
SET HEADING ON

@_TITLE 'List Statements in Shared Pool with the Most Loads'
COLUMN sql_text FORMAT A60
SELECT sql_text, loads 
FROM v$sqlarea
WHERE loads > 100 
ORDER BY loads DESC;


@_TITLE 'User Resource Usage'
COLUMN ses.sid FORMAT A4
COLUMN username FORMAT A14
COLUMN name FORMAT A44
SELECT 
    ses.sid, ses.username, sn.name, sest.value
FROM 
    v$session ses, v$statname sn, v$sesstat sest
WHERE 
    ses.sid=sest.sid
    AND sn.statistic# = sest.statistic#
    AND sest.value IS NOT NULL
    AND sest.value != 0            
order by 
    ses.username, ses.sid, sn.name
;

COLUMN "User Session" FORMAT A18;
COLUMN sql_text HEADING "Statement" WORD_WRAP

@_TITLE 'Cursors that Users currently have Open'
SELECT 
    username || '(' || v$session.sid || ')' "User Session",  
    sql_text 
FROM 
    v$open_cursor, v$session
WHERE 
    v$session.saddr = v$open_cursor.saddr    
/

@_TITLE 'Cursors Currently Running for a User'
SELECT 
    username || '(' || v$session.sid || ')' "User Session",  
    sql_text 
FROM 
    v$open_cursor, v$session
WHERE 
    v$session.sql_address = v$open_cursor.address
    AND v$session.sql_hash_value = v$open_cursor.hash_value
/
PROMPT     
PROMPT The following figures are the reloads required for SQL, PL/SQL,
PROMPT packages and procedures. The ideal is to have zero reloads because 
PROMPT a reload by definitions is where the object could not be maintained 
PROMPT in memory and Oracle was forced to throw it out of memory, and then
PROMPT a request has been made for it to be brought back in. If your reloads
PROMPT are very high, try enlarging the SHARED_POOL_SIZE parameter and
PROMPT re-check the figures. If the figures continue to come down, continue 
PROMPT the SHARED_POOL_SIZE in increments of 5 Meg.
PROMPT 

@_TITLE 'Total Shared Pool Reload Stats'

SELECT namespace, reloads 
FROM v$librarycache;

PROMPT 
PROMPT The following three queries obtain information on the SHARED_POOL_SIZE.
PROMPT 
PROMPT The first query lists the packages, procedures and functions in the 
PROMPT order of largest first.
PROMPT 
PROMPT The second query lists the number of reloads. Reloads can be very 
PROMPT damaging because memory has to be shuffled within the shared pool area
PROMPT to make way for a reload of the object.
PROMPT 
PROMPT The third parameter lists how many times each object has been executed.
PROMPT 
PROMPT Oracle has provided a procedure which is stored in $ORACLE_HOME/rdbms/admin
PROMPT called dbmspool.sql The SQL program produces 3 procedures. A procedure
PROMPT called keep (i.e. dbms_shared_pool.keep) can be run to pin a procedure in
PROMPT memory to ensure that it will not have to be re-loaded.    
PROMPT 
PROMPT Oracle 7.1.6 offers 2 new parameters that allow space to be reserved for
PROMPT procedures/packages above a selected size. This gives greater control 
PROMPT over the avoidance of fragmentation in the SHARED POOL.
PROMPT 
PROMPT See the parameters SHARED_POOL_RESERVED_SIZE and
PROMPT SHARED_POOL_RESERVED_MIN_ALLOC.
PROMPT 
PROMPT They are listed later in this report. 
PROMPT 


@_TITLE 'Memory Usage of Shared Pool'
COLUMN owner FORMAT A16
COLUMN name  FORMAT A36
COLUMN sharable_mem FORMAT 999,999,999
COLUMN executions   FORMAT 999,999,999

SELECT  
    owner, 
    name || ' - ' || type name, 
    sharable_mem 
FROM 
    v$db_object_cache
WHERE 
    sharable_mem > 10000
    AND type IN ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
ORDER BY 
    sharable_mem DESC
/

@_TITLE 'Loads into Shared Pool'

SELECT  
    owner, 
    name || ' - ' || type name, 
    loads , 
    sharable_mem 
FROM 
    v$db_object_cache
WHERE 
    type IN ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
ORDER BY 
    loads DESC
/

@_TITLE 'Executions of Objects in the Shared Pool'

select 
    owner, 
    name || ' - ' || type name, 
    executions 
FROM 
    v$db_object_cache
WHERE 
    type IN ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
ORDER BY 
    executions DESC
/

PROMPT 
PROMPT The next query lists the number of open cursors that each user is 
PROMPT currently utilising. Each SQL statement that is executed is stored
PROMPT partly in the Shared SQL Area and partly in the Private SQL Area.
PROMPT The private area is further broken into 2 parts, the persistent area
PROMPT and the runtime area. The persistent area is used for binding info. 
PROMPT The larger the number of columns in a query, the larger the persistent
PROMPT area. The size of the runtime area depends on the complexity of the
PROMPT statement. The type of statement is also a factor. An insert, update
PROMPT or delete statement will use more runtime area than a select. 
PROMPT 
PROMPT For insert, update and delete statements, the runtime area is freed
PROMPT immediately after the statement has been executed. For a query, the 
PROMPT runtime area is cleared only after all rows have been fetched or the
PROMPT query is cancelled. 
PROMPT 
PROMPT What has all this got to do with open cursors?
PROMPT 
PROMPT A private SQL area continues to exist until the corresponding cursor 
PROMPT is closed. Note: the runtime area is freed but the persistent (binding)
PROMPT area remains open. If the statement is re-used, leaving cursors open is
PROMPT not bad practice, if you have sufficient memory on your machine. Leaving
PROMPT cursors that are not likely to be used again is bad practice, once 
PROMPT again, particularly if you are short of memory. The number of private 
PROMPT areas is limited by the setting of OPEN_CURSORS init.ora parameter. The
PROMPT user process will continue to operate, despite having reached the OPEN_
PROMPT CURSOR limit. Cursors will be flushed and will need to be pe-parsed the
PROMPT next time they are accessed.
PROMPT 
PROMPT Recursive calls are used to handle the re-loading of the cursors if
PROMPT the have to be re-binded after being closed.
PROMPT 
PROMPT The data in the following query lists each user process, the number of
PROMPT recursive calls (the lower the better), the total opened cursors
PROMPT cumulative and the current opened cursors. If the number of current opened
PROMPT cursors is high (> 50), question why curors are not being closed. If the
PROMPT number of cumulative opened cursors and recursive calls is significantly 
PROMPT larger for some of the users, determine what transaction they are running
PROMPT and determine if they can leave cursors open to avoid having to re-bind
PROMPT the statements and avoid the associated CPU requirements.
PROMPT

DROP TABLE temp$user_cursors;

CREATE TABLE temp$user_cursors AS
SELECT 
    ss.username || '(' || se.sid || ') ' user_process, 
    SUM(DECODE(name, 'recursive calls', value)) "Recursive Calls",
    SUM(DECODE(name, 'opened cursors cumulative', value)) "Opened Cursors",
    SUM(DECODE(name, 'opened cursors current', value)) "Current Cursors"
FROM 
    v$session ss, v$sesstat se, v$statname sn
where  
    se.statistic# = sn.statistic#
    AND (name LIKE '%opened cursors current%'
         OR name LIKE '%recursive calls%'
         OR name LIKE '%opened cursors cumulative%')
    AND se.sid = ss.sid
    AND ss.username IS NOT NULL
GROUP BY 
    ss.username || '(' || se.sid || ') '
/

@_TITLE 'Per Session Current Cursor Usage '

COLUMN USER_PROCESS FORMAT A25;
COLUMN "Recursive Calls" FORMAT 999,999,999;
COLUMN "Opened Cursors" FORMAT 99,999;
COLUMN "Current Cursors" FORMAT 99,999;

SELECT * 
FROM temp$user_cursors   
ORDER BY "Recursive Calls" DESC
/

DROP TABLE temp$user_cursors;

PROMPT 
PROMPT The next output lists the CPU usage on a per-user basis. If a user process
PROMPT has considerably more CPU usage, it is worth investigating. The causes can
PROMPT be many, ranging from untuned SQL statements, indexes missing, cursors
PROMPT being closed too often, or an ad hoc user running rampant. The high CPU 
PROMPT usage may also be acceptable depending on the type of tasks that the person
PROMPT is performing.
PROMPT 

@_TITLE 'CPU Used By Session Information'

SELECT 
    SUBSTR(name, 1, 30) parameter,
    ss.username || '(' || se.sid || ') ' user_process, 
    value
FROM 
    v$session ss, v$sesstat se, v$statname sn
WHERE  
    se.statistic# = sn.statistic#
    AND name like '%CPU used by this session%'
    AND se.sid = ss.sid
ORDER BY 
    SUBSTR(name, 1, 25), value DESC
/

@_TITLE 'Internal Oracle Locking Problems'
SET HEADING OFF

SELECT 
    'Warning: Enqueue Timeouts are ' || value || '. They should be zero.' nl,
    'Increase the INIT.ora parameter ENQUEUE_RESOURCES'
FROM 
    v$sysstat
WHERE 
    name = 'enqueue timeouts'
    AND value > 0
/

PROMPT 
PROMPT The following report lists tables without any indexes on then whatsoever.
PROMPT It is unusual for tables not to need an index. Even small tables require
PROMPT an index to guarantee uniqueness. Small tables also  require indexes for
PROMPT joining, because a full table scan will always drive a query (unless a 
PROMPT hint is used). If you are scanning through many rows in a large table
PROMPT using an index range scan and are looking up a reference table to expand 
PROMPT a code into the description stored in the smaller table, the query will 
PROMPT take considerably longer because the small table will be the driving 
PROMPT table. Larger tables can drag a machine to its knees if they are 
PROMPT continually accessed without going through an index. 
PROMPT 

@_TITLE 'Report on all Tables Without Indexes'
SET HEADING ON
BREAK ON owner SKIP 1

SELECT owner, table_name FROM all_tables
MINUS
SELECT owner, table_name FROM all_indexes;

PROMPT 
PROMPT The next enquiry gives you a list of indexes that have the same column 
PROMPT as the leading column in the index. These indexes can cause problems if
PROMPT queries use the incorrect index. e.g. Oracle will utilise the index that
PROMPT was created most recently if two indexes are of equal ranking. This can 
PROMPT cause different indexes to be utilised from one environment to the next
PROMPT e.g. from DEV to QA to PROD. Each environment may have had its indexes 
PROMPT created in a different sequence. I strongly recommend that you use hints
PROMPT in you programs to overcome these problems and force specific queries to 
PROMPT use a specified index.
PROMPT 
PROMPT The following information does not automatically indicate that an index
PROMPT is incorrect, but each index should be viewed to justify its existence.
PROMPT 

@_TITLE 'Indexes which may be Superfluous'
COLUMN table_owner FORMAT A20;
COLUMN table_name  FORMAT A27;
COLUMN column_name FORMAT A30;

SELECT 
    table_owner, table_name ,column_name 
FROM 
    all_ind_columns 
WHERE  
    column_position =1
GROUP BY 
    table_owner, table_name , column_name
HAVING  
    COUNT(*) > 1 
/

PROMPT 
PROMPT The following output lists all foreign keys that do not have an index
PROMPT on the Child table, for example, we have a foreign key on the EMP table
PROMPT to make sure that it has a valid DEPT row existing. The foreign key is 
PROMPT placed on the EMP (deptno) column pointing to the DEPT (deptno) primary
PROMPT key.
PROMPT 
PROMPT Obviously the parent table DEPT requires an index on deptno for the
PROMPT foreign key to point to. The effect of the foreign key that is not
PROMPT widely known is that unless an index is placed on the child table on
PROMPT the columns that are used in the foreign key, a share lock occurs on the 
PROMPT parent table for the duration of the insert, update or delete on the 
PROMPT child table. 
PROMPT 
PROMPT What is a share lock, you ask? The effect of a share lock is that all
PROMPT query users hoping to access the table have to wait until a single update
PROMPT user on the table completes his/her update. Update users cannot perform 
PROMPT their update until all query users complete their queries against the table.
PROMPT The bottom line is that if the parent table is a volatile table, the 
PROMPT share lock can cause the most incredible performance degradation. At a 
PROMPT recent benchmark, we had the entire benchmark grind to a halt because of this
PROMPT locking situation. If the parent table is a non-volatile table, you may
PROMPT be able to get away without the index on the child table, because the lock
PROMPT on the parent table is of no importance.
PROMPT 
PROMPT The negative factor of the index on the child table is that I have observed
PROMPT tables with as many as 30 indexes on them and the performance degradation 
PROMPT has been caused by maintaining the excessive number of indexes. My advice 
PROMPT to these sites has been to only use foriegn key constraints on columns
PROMPT that have an index which can be used for other purposes (e.g. reporting)
PROMPT or that point to a non-volatile reference table.  Most tables have difficulty
PROMPT maintaining acceptable performance if they have > 10 indexes on them.
PROMPT 
PROMPT You may wish to take the foreign keys offline during the day and put them 
PROMPT online at night to report any errors into an exceptions table. You should 
PROMPT do this when the parent table is not being accessed.
PROMPT 

@_TITLE 'UNINDEXED FOREIGN KEYS'
SET HEADING OFF

SELECT 
    acc.owner ||' -> '|| acc.constraint_name || ' (' || acc.column_name
        || '[' || acc.position || '])' || ' ***** Missing Index'
FROM   
    all_cons_columns acc, all_constraints ac
WHERE  
    ac.constraint_name = acc.constraint_name
    AND ac.constraint_type = 'R'
    AND (acc.owner, acc.table_name, acc.column_name, acc.position) in (
        SELECT acc.owner, acc.table_name, acc.column_name, acc.position 
        FROM all_cons_columns acc, all_constraints ac
        WHERE ac.constraint_name = acc.constraint_name
        AND ac.constraint_type = 'R'
        MINUS
        SELECT table_owner, table_name, column_name, column_position
        FROM all_ind_columns
        )
ORDER BY 
    acc.owner, acc.constraint_name, acc.column_name, acc.position
;
SET HEADING ON
   
PROMPT 
PROMPT Having multiple extents on objects causes performance degradation when 
PROMPT performing full scans. The throwing of the extents requires recursive 
PROMPT calls to the uet$ and fet$ tables (used extents and free extents 
PROMPT dictionary tables) which is also particularly damaging to performance
PROMPT if done too often. Most of the database objects below can potentially
PROMPT require re-building, but keep the following exceptions in mind...
PROMPT 
PROMPT I have observed performance degradation as much as 10 times longer
PROMPT runtime for multiple extents compared to a single extent.
PROMPT 
PROMPT (1) Parallel data loading and other parallel processing depends on 
PROMPT objects having multiple extents for them to operate correctly. 
PROMPT 
PROMPT (2) Rollback segments require multiple extents to service multiple users
PROMPT sharing  the rollback segment.
PROMPT 
PROMPT (3) Multiple extents on a very large table will have a much less          
PROMPT harmful effect than multiple extents on a smaller table. Of course, the
PROMPT re-building of the table (and its indexes) may take an excessive amount
PROMPT of time. 
PROMPT 
PROMPT If you do need to do a re-org, consider the UNRECOVERABLE option
PROMPT to bypass the buffer cache and parallel index loading, to speed up the
PROMPT re-build.
PROMPT 
PROMPT One other thing you may consider is to have a lower PCTFREE when
PROMPT rebuilding the table and then altering the table to enlarge the PCTFREE
PROMPT to a larger value after the tables data has been loaded. Make sure that
PROMPT you re-load you data without indexes, constraints and triggers. Add the 
PROMPT indexes and constraints after the data has been loaded. Add the triggers
PROMPT also, but keep in mind that you may have to perform the tasks that the 
PROMPT trigger would have performed, because the trigger only becomes effective
PROMPT on data created after the trigger has been created.
PROMPT 


@_TITLE 'List All Segments with More than 5 Extents'
COLUMN segment_name    FORMAT A25;
COLUMN owner           FORMAT A12;
COLUMN tablespace_name FORMAT A12 HEADING tablespace;
COLUMN sizing          FORMAT 999,999,999;
BREAK ON owner ON tablespace_name;

SELECT 
    owner, 
    tablespace_name, 
    segment_name || DECODE(segment_type,
        'TABLE', '[T]', 
        'INDEX', '[I]', 
        'ROLLBACK', '[R]', 
        '[O]') segment_name, 
    SUM(bytes) sizing, 
    COUNT(*) seg_count
FROM 
    dba_extents
GROUP BY 
    owner, 
    tablespace_name, 
    segment_name || DECODE(segment_type,
        'TABLE', '[T]', 
        'INDEX', '[I]',
        'ROLLBACK', '[R]', 
        '[O]')
HAVING 
    COUNT(*) > 5
;

PROMPT 
PROMPT The next figures list the free space on a per tablespace to assist
PROMPT with the re-building of the table.
PROMPT 

@_TITLE 'Free Space in Total By Tablespace'
BREAK ON tablespace_name;
CLEAR COLUMNS

SELECT tablespace_name, SUM(bytes) sizing 
FROM dba_free_space
GROUP BY tablespace_name;

@_TITLE 'Free Extent Sizes per Tablespace'

SELECT tablespace_name, bytes sizing
FROM user_free_space
WHERE bytes > 512000 
ORDER BY tablespace_name, bytes DESC;

PROMPT 
PROMPT The following output lists the sizes of all datafiles being used by 
PROMPT the database (excluding control files)
PROMPT 
PROMPT Make sure that your data files are evenly spread across disks from a 
PROMPT performance perspective.
PROMPT 

@_TITLE 'Data File Sizes'
COLUMN file_name FORMAT A50;
COLUMN bytes FORMAT 999,999,999,999

SELECT file_name, bytes 
FROM dba_data_files
/

@_TITLE 'Additional Extent Information'
COLUMN name HEADING "Tablespace";
COLUMN "Total Free" FORMAT 99,999,999,999
COLUMN "Largest Free" FORMAT 99,999,999,999
COLUMN "Default Initial" FORMAT 9,999,999

SELECT 
    name, 
    SUM(length) * 4096 "Total Free", 
    MAX(length) * 4096 "Largest Free",
    dflinit * 4096 "Default Initial"
FROM 
    sys.fet$ a, sys.ts$ b
WHERE 
    a.ts# =b.ts#
GROUP BY 
    name, dflinit
/

PROMPT 
PROMPT The next output is not strictly tuning, but it gives you a list of all    
PROMPT database objects that will fail when they attempt to throw their next extent
PROMPT due to a lack of a free extent that is of sufficient size in the same
PROMPT tablespace as where the object resides. If the problem happens to occur 
PROMPT on a dictionary table, the whole database can potentially freeze, which I
PROMPT suppose is response related. 
PROMPT 

@_TITLE 'Database Objects that will have Trouble Throwing Extents'
COLUMN owner FORMAT A10;
COLUMN segment_name FORMAT A22;
COLUMN segment_type FORMAT A10;
COLUMN tablespace_name FORMAT A14;
COLUMN next_extent FORMAT 999,999,999;

SELECT 
    seg.owner, 
    seg.segment_name,
    seg.segment_type, 
    seg.tablespace_name,
    t.next_extent
FROM 
    sys.dba_segments seg,
    sys.dba_tables t
WHERE  
    (seg.segment_type = 'TABLE'
    AND seg.segment_name = t.table_name
    AND seg.owner = t.owner
    AND NOT EXISTS (
        SELECT tablespace_name
        FROM dba_free_space free
        WHERE free.tablespace_name = t.tablespace_name
        AND bytes >= t.next_extent
        )
    )
UNION
SELECT 
    seg.owner, 
    seg.segment_name,
    seg.segment_type, 
    seg.tablespace_name,
    DECODE (seg.segment_type,
        'CLUSTER', c.next_extent)
FROM 
    sys.dba_segments seg,
    sys.dba_clusters c 
WHERE   
    (seg.segment_type = 'CLUSTER'
    AND seg.segment_name = c.cluster_name
    AND seg.owner = c.owner
    AND NOT EXISTS (
        SELECT tablespace_name
        FROM dba_free_space free
        WHERE free.tablespace_name = c.tablespace_name
        AND bytes >= c.next_extent     
        )
    )
UNION
SELECT 
    seg.owner, 
    seg.segment_name,
    seg.segment_type, 
    seg.tablespace_name,
    DECODE (seg.segment_type,
        'INDEX', i.next_extent )
FROM 
    sys.dba_segments seg,
    sys.dba_indexes i
WHERE  
    (seg.segment_type = 'INDEX'
    AND seg.segment_name = i.index_name
    AND seg.owner = i.owner
    AND NOT EXISTS (
        SELECT tablespace_name
        FROM dba_free_space free
        WHERE free.tablespace_name = i.tablespace_name
        AND bytes >= i.next_extent
        )
    )
UNION
SELECT 
    seg.owner, 
    seg.segment_name,
    seg.segment_type, 
    seg.tablespace_name,
    DECODE (seg.segment_type,
        'ROLLBACK', r.next_extent)
FROM 
    sys.dba_segments seg,
    sys.dba_rollback_segs r
WHERE  
    (seg.segment_type = 'ROLLBACK'
    AND seg.segment_name = r.segment_name
    AND seg.owner = r.owner
    AND NOT EXISTS (
        SELECT tablespace_name
        FROM dba_free_space free
        WHERE free.tablespace_name = r.tablespace_name
        AND bytes >= r.next_extent     
        )
    ) 
/

PROMPT 
PROMPT The following output lists latch contention. A latch is used to protect
PROMPT data structures inside the SGA and provide fast access to the database         
PROMPT buffers. A process that needs a latch has to own the latch which it must
PROMPT access from a hash table. If a process has problems obtaining a latch, it
PROMPT must wait until it is able to obtain one. Latch contention is more     
PROMPT predominant on multi CPU applications. Spinning on a latch avoids the 
PROMPT more costly operation of accessing the latch via conventional operating
PROMPT system queueing mechanism.
PROMPT 
PROMPT 
PROMPT The output from the following report which can be tuned are the redo 
PROMPT latches.  The redo latches are the "redo allocation" and the "redo copy"
PROMPT latches. The redo allocation latch serially writes all changes to the 
PROMPT database to the log buffer. On a single CPU system, you cannot repair       
PROMPT contention on this latch, and in fact latches should be minimal on a 
PROMPT single CPU system. 
PROMPT 
PROMPT Latch contention tends to be much more evident on 
PROMPT multi CPU machines. If you have a multi-CPU machine, you must set the 
PROMPT INIT.ora parameter equal to the number of CPUs of your machine. Setting 
PROMPT this parameter allows a second latch (copy latch) to access the log buffer. 
PROMPT 
PROMPT All changed data which is written to the log buffer which is larger than the
PROMPT value specified in the parameter LOG_SMALL_ENTRY_MAX_SIZE is written to the
PROMPT copy latch and all those smaller that or equal to the size use the redo
PROMPT allocation latch. If you experience contention on the copy latch, you should
PROMPT decrease the  LOG_SMALL_ENTRY_MAX_SIZE to force more entries through the
PROMPT redo allocation latch. If the redo allocation latch has the problem, you
PROMPT can increase  LOG_SMALL_ENTRY_MAX_SIZE to force more entries through the 
PROMPT redo copy latch.
PROMPT 
PROMPT Another interesting latch contention figure is that for "cache buffer chains"
PROMPT and "cache buffer lru chains". This is latch waits on buffer cache accesses.
PROMPT The worst case I have seen on these waits was when a production DBA had 
PROMPT decided to turn on DB_LRU_EXTENDED_STATISTICS and DB_BLOCK_LRU_STATISTICS. 
PROMPT The DBA got some magnificent reports on the effect of increasing and 
PROMPT decreasing the DB_BLOCK_BUFFERS (buffer cache) but the production users
PROMPT weren't too happy with the significant response degradation. 
PROMPT 
PROMPT If you get latch contention on the a multi CPU computer, you can decrease
PROMPT the spin_count. The default spin count on most machines is set to 200. I 
PROMPT know of at least one benchmark on HP's where the spin_count was set to 1, 
PROMPT to achieve optimal throughput. I have been told that on single CPU machines
PROMPT you can increase a value "_Latch_Wait_postings" to say 20 and this will     
PROMPT provide a similar response improvement. Note: the _ in front of the parameter
PROMPT name indicates that it is a secret parameter. We are never totally sure if
PROMPT the secret parameters work. They appear to be on again/ off again from one
PROMPT version of Oracle to the next. See the output at the beginning of this report
PROMPT for a full list of undocumented parameters. 
PROMPT 
PROMPT Speaking of undocumented parameters, we used to be able to decrease the
PROMPT _DB_WRITER_MAX_SCAN_CNT and increase the _DB_BLOCK_WRITE_BATCH to avoid latch
PROMPT contention. Whether the parameters take effect will vary from one version of
PROMPT Oracle to the next. Try them out on your system only if you are experiencing
PROMPT latch contention.
PROMPT 
PROMPT I've observed latch contention on the library cache. Stay tuned on how to
PROMPT overcome this problem. I'll have to learn this one as well.
PROMPT 

@_CLEAR
@_TITLE 'Latch Gets and Misses'

SELECT 
    SUBSTR(name, 1, 25) name, 
    gets, 
    misses, 
    immediate_gets, 
    immediate_misses
FROM 
    v$latch
WHERE 
    misses > 0
    OR immediate_misses > 0
/

PROMPT 
PROMPT The following query shows the minimum and maximum times between log switches.
PROMPT Typically, the minimum time should exceed a few minutes. The average figure
PROMPT may be effected by no overnight activity taking place. If the switches are 
PROMPT less than 30 seconds on a regular basis (see the second query), I would  
PROMPT suggest that you should enlarge the size of the redo log files.
PROMPT 

@_TITLE 'Minimum and Average time Between Checkpoints'
COLUMN "Min Minutes BW Checkpoints" FORMAT 999,999.99;
COLUMN "Avg Minutes BW Checkpoints" FORMAT 999,999.99;

SELECT 
    MIN(TO_NUMBER(TO_DATE(lh2.first_time, 'mm/dd/yy hh24:mi:ss') 
              -   TO_DATE(lh1.first_time, 'mm/dd/yy hh24:mi:ss') )
                              * 24 * 60) "Min Minutes BW Checkpoints",
    AVG(TO_NUMBER(TO_DATE(lh2.first_time, 'mm/dd/yy hh24:mi:ss')
              -   TO_DATE(lh1.first_time, 'mm/dd/yy hh24:mi:ss') )
                              * 24 * 60) "Avg Minutes BW Checkpoints"
FROM 
    v$loghist lh1, 
    v$loghist lh2
WHERE 
    lh1.sequence# + 1 = lh2.sequence#
    AND lh1.sequence# < (
        SELECT MAX(sequence#)
        FROM  v$loghist 
        )
/

DROP TABLE temp$min_bw_checkpoints;

CREATE TABLE temp$min_bw_checkpoints AS
    SELECT 
        TO_NUMBER(TO_DATE(lh2.first_time, 'mm/dd/yy hh24:mi:ss') 
              -   TO_DATE(lh1.first_time, 'mm/dd/yy hh24:mi:ss') )
                              * 24 * 60 "Minutes BW Checkpoints"
    FROM 
        v$loghist lh1, v$loghist lh2
    WHERE 
        lh1.sequence# + 1 = lh2.sequence#
        AND lh1.sequence# < (
            SELECT MAX(sequence#)
            FROM v$loghist 
        )
/


@_TITLE 'Minutes Between Checkpoints'
COLUMN "Minutes BW Checkpoints" FORMAT 999,999.99

SELECT "Minutes BW Checkpoints" 
FROM temp$min_bw_checkpoints
ORDER BY "Minutes BW Checkpoints"
/

DROP TABLE temp$min_bw_checkpoints;

PROMPT 
PROMPT The following output assists you with tuning the LOG_BUFFER. The size of the
PROMPT log buffer is set by assigning a value to the INIT.ora parameter LOG_BUFFER.
PROMPT 
PROMPT All changes are written to your redo logs via the log buffer. If your log 
PROMPT buffer is too small it can cause excessive disk I/Os on the disks that 
PROMPT contain your redo logs. The problem can be made worse if you have archiving
PROMPT turned on because as well as writing to the redo logs, Oracle has to also 
PROMPT read from the redo logs and copy the file to the archive logs. To overcome 
PROMPT this problem, I suggest that you have 4 redo logs, typically 5 Meg or larger
PROMPT in size  and alternate the redo logs from one disk to another, that  is
PROMPT redo log 1 is on disk 1 , redo log 2 is on disk 2, redo log 3 is on disk 1
PROMPT and redo log 4 is on disk 2.
PROMPT 
PROMPT This will ensure that the previous log being archived will be on a different
PROMPT disk to the redo log being written to.
PROMPT 
PROMPT The following statistics also indicate inefficiencies with the log buffer
PROMPT being too small. Typically a large site will have the LOG_BUFFER 500k or
PROMPT larger.
PROMPT 
PROMPT The "redo log space wait time" indicates that the user process had to wait to 
PROMPT get space in the redo file. This indicates that the current log buffer was
PROMPT being written from and the process would have to wait. Enlarging the log 
PROMPT buffer usually overcomes this problem. The closer the value is to zero, the
PROMPT better your log buffer is tuned.
PROMPT 
PROMPT The "redo log space request" indicates the number of times a user process has
PROMPT to wait for space in redo log buffer. It is often caused by the archiver being 
PROMPT lazy and the log writer can't write from the log buffer to the redo log 
PROMPT because the redo log has not been copied by the ARCH process. One possible
PROMPT cause of this problem is where Hot Backups are taking place on files that are
PROMPT being written to heavily. Note: for the duration of the hot backups, an 
PROMPT entire block is written out to the log buffer and the redo logs for each
PROMPT change to the database, as compared to just the  writing the characters that
PROMPT have been modified.
PROMPT 
PROMPT There is a parameter _LOG_BLOCKS_DURING_BACKUP which is supposed to overcome
PROMPT the Hot backup problem. It will pay to check if the parameter is functional
PROMPT for your version of the RDBMS with Oracle. It can avoid severe bottlenecks.
PROMPT 
PROMPT A sensible approach for overnight processing is to time your Hot Backups, if
PROMPT they are really required, (a lot of sites have them just for the sake of saying
PROMPT that they are running them) to occur when the datafiles being backed up have
PROMPT very little or preferably NO activity occurring against them.
PROMPT 
PROMPT The "redo buffer allocation retries" are where the redo writer is waiting for 
PROMPT the log writer to complete the clearing out of all of the dirty buffers from 
PROMPT the buffer cache. Only then, can the redo writer continue onto the next
PROMPT redo log. This problem is usually caused by having the LOG_BUFFER parameter
PROMPT too small, but can also be caused by having the buffer cache too small (see
PROMPT the DB_BLOCK_BUFFERS parameter).
PROMPT 

@_CLEAR
@_TITLE 'Extra LOG_BUFFER and Redo Log Tuning Information'
COLUMN name FORMAT A50

SELECT SUBSTR(name, 1, 25) name, value 
FROM v$sysstat
WHERE name LIKE 'redo%'                     
AND value > 0
/

PROMPT 
PROMPT Oracle 7.1.5 introduced a new mechanism for improving the performance of
PROMPT the shared pool area. When a user loads a large package or
PROMPT procedure into the shared pool it has to search for large contiguous pieces
PROMPT of memory. If there is not enough memory available, it has to make the 
PROMPT free memory available. This is particularly damaging to performance.
PROMPT 
PROMPT The new mechanism introduced in 7.1.5 allows memory to be reserved to
PROMPT satisfy loading in large packages/procedures without having too disruptive
PROMPT an effect on the shared pool area performance. Smaller objects will not
PROMPT be able to fragment the area because all objects smaller than the size 
PROMPT specified in the parameter SHARED_POOL_RESERVED_MIN_ALLOC will be placed
PROMPT into a shared pool area especially reserved for the smaller objects.
PROMPT 
PROMPT The total amount of space given to the larger area is specified by the 
PROMPT parameter SHARED_POOL_RESERVED_SIZE.  The amount of space assigned to the
PROMPT small objects is the SHARED_POOL_SIZE less the SHARED_POOL_RESERVED_SIZE.
PROMPT 
PROMPT There is also a new procedure that controls the amount of flushing from 
PROMPT the shared pool to make way for new objects being moved into the pool. The 
PROMPT RDBMS will continue to flush unused objects from the buffer pool until enough
PROMPT free memory is available to fit the object into the shared pool. If there is
PROMPT not enough available memory even after all of the objects have been flushed,
PROMPT Oracle presents a 4031 error. The problem is that to get to a state of finding
PROMPT that there is not enough memory can be particularly resource consuming.
PROMPT 
PROMPT The dbms_shared_pool.ABORT_REQUEST_THRESHOLD parameter sets the limit on
PROMPT the size of objects allowed to flush the shared pool if the free space is
PROMPT not sufficient to satisfy the request size. All objects larger than the 
PROMPT setting (valid range is 5,000 to 2,147,483,647) will immediately return an
PROMPT error 4031 is suuficient free space is not available. 
PROMPT 

@_TITLE 'The Reserve Pool Settings for the Shared Pool'

SELECT 
    SUBSTR(name, 1, 32) "Parameter", 
    SUBSTR(value, 1, 12) "Setting"
FROM v$parameter
WHERE name LIKE '%reser%'
/

SET HEADING OFF
@_TITLE 'Shared Pool Reserved Size Recommendation'
COLUMN nl NEWLINE

SELECT 
    'You may need to increase the SHARED_POOL_RESERVED_SIZE' nl,
    'Request Failures = ' || request_failures
FROM 
    v$shared_pool_reserved
WHERE 
    request_failures > 0
    AND 0 != ( 
        SELECT TO_NUMBER(value) 
        FROM v$parameter 
        WHERE name = 'shared_pool_reserved_size' 
        )
;

SELECT 
    'You may be able to decrease the SHARED_POOL_RESERVED_SIZE' nl,
    'Request Failures = ' || request_failures
FROM 
    v$shared_pool_reserved
WHERE 
    request_failures < 5
    AND 0 != ( 
        SELECT TO_NUMBER(value) 
        FROM v$parameter 
        WHERE name = 'shared_pool_reserved_size' 
    )
;

@_TITLE 'Checking Locations of Database Files' 
SET HEADING OFF
SELECT value FROM v$parameter
WHERE name = 'log_archive_dest'
UNION
SELECT name FROM v$datafile 
UNION
SELECT member FROM v$logfile 
/

SET HEADING ON
@_TITLE 'Columns with Inconsistent Data Lengths'
COLUMN owner FORMAT A12;
COLUMN column_name FORMAT A25;
COLUMN "Characteristics" FORMAT A40;
BREAK ON owner ON column_name;
  
SELECT 
    owner, 
    column_name, 
    table_name || ' ' || data_type || '(' ||
        DECODE(data_type, 
            'NUMBER', data_precision, 
            data_length
            ) || ')' "Characteristics"
FROM 
    all_tab_columns 
WHERE  
    (column_name, owner) IN (
        SELECT 
            column_name, owner
        FROM 
            all_tab_columns
        GROUP BY 
            column_name, owner
        HAVING 
            MIN(DECODE(data_type, 
                'NUMBER', data_precision, 
                data_length
            )) 
            < 
            MAX(DECODE(data_type, 
                'NUMBER', data_precision, 
                data_length
            )) 
        )
AND owner NOT IN ('SYS', 'SYSTEM')
AND '&Check_column_lengths_y_n' in ('Y','y', 'YES')
/

@_TITLE 'Listing all Invalid Objects'

SELECT owner, object_type, object_name, status 
FROM all_objects
WHERE status = 'INVALID'
ORDER BY owner, object_type, object_name
/

@_TITLE 'Listing all Triggers and their Status'

SELECT table_name, trigger_name, status
FROM all_triggers
ORDER BY table_name, trigger_name
/

@_TITLE 'Listing all Pinned Packages'

SELECT name, kept
FROM v$db_object_cache
WHERE kept NOT LIKE 'N%'
/

@_title 'Tablespace Details'

SELECT tablespace_name, initial_extent, next_extent, pct_increase
FROM dba_tablespaces
/     

@_TITLE 'Users that Have The SYSTEM Tablespace as Their Default'

SELECT username 
FROM dba_users
WHERE default_tablespace = 'SYSTEM' OR temporary_tablespace='SYSTEM'
/

@_END
