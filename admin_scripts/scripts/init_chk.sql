REM
REM   This script checks various key INIT.ORA parameters and advises on their 
REM   appropriateness.
REM
REM   Author: Mark Gurry
REM

@_BEGIN
SET PAGESIZE 1000
SET HEADING OFF

SELECT 
    'Archiving is not turned on for the database! This means that recovery is only ' nl,
    'possible up to the last cold backup or export. This is not good practice for ' nl,
    'a production database. Check if this is acceptable.' nl
FROM v$parameter
WHERE name = 'log_archive_start'
AND value = 'FALSE'
/

select 
    'TIMES_STATISTICS has been set to TRUE. This is useful for performance ' nl,
    'monitoring but will slow performance by between 5 and 10%. If there are ' nl,
    'serious performance problems consider turning it off.' nl
FROM v$parameter
WHERE name = 'timed_statistics'
AND value = 'TRUE' 
/

SELECT 
    'The buffer cache (DB_BLOCK_BUFFERS * DB_BLOCK_SIZE) is set too low for ' nl,
    'a production database. It is set to ' || TO_CHAR(bytes) || '. It should be at least' nl,
    '16 Megabytes for a serious production system. If you have sufficient ' nl,
    'free memory, consider increasing it.' nl
FROM v$sgastat  
WHERE name = 'db_block_buffers' 
AND bytes < 16000000
/

SELECT 
    'Your DB_BLOCK_SIZE is below the minimum recommended for an Oracle database. ' nl,
    'The minimum recommended is 4k. Unfortunately to increase the parameter, you ' nl,
    'need to re-build the database. If a database re-organisation or re-build is ' nl,
    'planned, create the database with DB_BLOCK_SIZE set to 4K of 8K.' nl
FROM v$parameter
WHERE name = 'db_block_size'           
AND value < '4096'     
/

SELECT 
    'Your SORT_AREA_RETAINED_SIZE and SORT_AREA_SIZE are set to the same value ' nl,
    '(' || a.value || '). Unless you are running a database which is totally dedicated ' nl,
    'to large batch jobs, it is best to allocate the extra memory only to the ' nl,
    'people that need it. Typical settings are 64K for SORT_AREA_RETAINED_SIZE ' nl,
    'and 2M for SORT_AREA_SIZE.' nl
FROM v$parameter a , v$parameter b
WHERE a.name = 'sort_area_size'
AND b.name = 'sort_area_retained_size' 
AND b.value = a.value
/

SELECT 
    'The SEQUENCE_CACHE_ENTRIES is undersized. It should ideally be sized to fit all ' nl,
    'of the cached entries required for all sequences. The parameter is set to '
    || b.value || '.' nl,
    'It should be set to '|| SUM(a.cache_size) || '.'
FROM sys.dba_sequences a, v$parameter b
WHERE b.name = 'sequence_cache_entries'
GROUP BY b.value
HAVING SUM(a.cache_size) < b.value
/


SELECT 
    'Your LOG_BUFFER may be able to be enlarged to improve performance. It is ' nl,
    'currently set to ' || b.value ||'. There have been a number of redo log space ' nl,
    'request (' || a.value || ') waits.' nl,
    'Consider enlarging the LOG_BUFFER to a value such as ' || b.value * 1.5 || '.'
FROM v$parameter b, v$sysstat a
WHERE b.name = 'log_buffer'
AND a.name = 'redo log space requests'
AND a.value > 50 
AND b.value < (SELECT 1000000 FROM DUAL)
/

SELECT 
    'Warning: Enqueue timeouts are ' || value ||'. They should be zero if the INIT.ora ' nl,
    'parameter is high enough. Try increasing INIT.ora parameter ENQUEUE_RESOURCES ' nl,
    'and see if the timeouts reduces.'
FROM v$sysstat
WHERE name = 'enqueue timeouts'
AND value > 0
/

@_END

