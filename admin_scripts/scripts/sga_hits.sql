REM
REM PURPOSE:
REM
REM     This report provides information critical to assist in tuning the
REM     various buffers within the ORACLE7 system global area (SGA).  
REM     OS memory monitoring tools should always be used in conjunction
REM     with cache hit ratio reports.
REM
REM GENERAL GUIDELINES:
REM
REM     Data Block Cache - from 0.90 to 0.97 
REM         Increase the instance parameter
REM         DB_BLOCK_BUFFERS to increase hit ratio.
REM     Shared Pool
REM         Shared SQL Buffers (Library Cache)
REM             Cache Hit Ratio -  0.85 and more 
REM                 Highly application dependent, increase
REM                 the instance param SHARED_POOL_SIZE 
REM                 to increase hit ratio.
REM             Avg. Users Per Stmt.
REM                 The average number of users who execute a SQL statement.
REM             Avg. Execs Per Stmt.
REM                 The average number of times that each statement gets
REM                 executed.
REM             Data Dictionary Cache Hit Ratio - 0.95 and more
REM                 Increase the instance param
REM                 SHARED_POOL_SIZE to increase hit ratio.
REM
REM AUTHOR: 
REM     Craig A. Shallahamer, Oracle US     
REM     (c)1994 Oracle Corporation     
REM

@_BEGIN
@_HIDE

COLUMN val2 NEW_VALUE lib NOPRINT
SELECT 1 - (SUM(reloads) / SUM(pins)) val2
FROM v$librarycache
/

COLUMN val2 NEW_VALUE dict NOPRINT
SELECT 1 - (SUM(getmisses) / SUM(gets)) val2
FROM v$rowcache
/

COLUMN val2 NEW_VALUE phys_reads NOPRINT
SELECT value val2
FROM v$sysstat
WHERE name = 'physical reads'
/

COLUMN val2 NEW_VALUE log1_reads NOPRINT
SELECT value val2
FROM v$sysstat
WHERE name = 'db block gets'
/

COLUMN val2 NEW_VALUE log2_reads NOPRINT
SELECT value val2
FROM v$sysstat
WHERE name = 'consistent gets'
/

COLUMN val2 NEW_VALUE chr NOPRINT
SELECT 1 - (&phys_reads / (&log1_reads + &log2_reads)) val2
FROM DUAL
/

COLUMN val2 NEW_VALUE avg_users_cursor NOPRINT
COLUMN val3 NEW_VALUE avg_stmts_exe NOPRINT
SELECT
    SUM(users_opening) / COUNT(*) val2,
    SUM(executions) / COUNT(*) val3
FROM v$sqlarea
/

@_TITLE 'SGA CACHE HIT RATIOS'
SET HEADING OFF

SELECT
    'Data Block Buffer Hit Ratio:   ' || &chr               || &CR ||
    'Shared SQL Pool'                                       || &CR ||
    '    Dictionary Hit Ratio:      ' || &dict              || &CR ||
    '    Shared SQL Buffers (Library Cache)'                || &CR ||
    '        Cache Hit Ratio:       ' || &lib               || &CR ||
    '        Avg. Users/Stmt:       ' || &avg_users_cursor  || &CR ||
    '        Avg. Execs/Stmt:       ' || &avg_stmts_exe
FROM DUAL
/

@_END


