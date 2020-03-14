REM 
REM PURPOSE:
REM
REM     This report provides information critical to aid in tuning the 
REM     shared pool's library cache. The shared pool resides within the
REM     ORACLE7 system global area (SGA). The shared pool contains both
REM     the library cache and the data dictionary cache.  
REM
REM     OS memory monitoring tools should always be used in conjunction 
REM     with memory related reports.
REM
REM OUTPUT DEFINITIONS:
REM    
REM     Size - The value of the instance parameter shared_pool_size
REM     Used sharable - Total memory used which contains memory structures 
REM         that can be shared between users, such as a SQL statement parse 
REM         tree.
REM     Used persistent - Total memory used which contains memory 
REM         structures that will remain regardless of who runs the statement 
REM         or how many times the statement is run.
REM     Used runtime - Total memory used which contains memory structures 
REM         that each user owns and no one else can access, such as the 
REM         current rowid (when running MTS).
REM     Available - Total Size minus Total Used.
REM     Number of SQL statements - The number of SQL statements currently 
REM         loaded in the shared pool's library cache.
REM     Number of programatic constructs - The number of SQL programatic
REM         constructs (procedures, functions, etc.) currently loaded into 
REM         the shared pool's library cache.  
REM     Kept programatic construct chunks - The number of programatic 
REM         constructs that have been pinned by someone into the library 
REM         cache. Programatic constructs can be manually pinned in the 
REM         library cache. In the "code" this is referred to as a "keep."  
REM     Kept programatic construct chunks size - The total size (bytes) 
REM         of kept programatic constructs in the library cache.
REM     Pinned statements - The number of SQL statements currently pinned 
REM         in the library cache. These "pinnings" are implicit and are 
REM         different than a "kept" construct.
REM     Pinned statement size - The total size (bytes) of pinned SQL 
REM         statements residing in the library cache.
REM
REM AUTHOR: 
REM     Craig A. Shallahamer, Oracle US     
REM     (c)1994 Oracle Corporation
REM

@_BEGIN
@_HIDE

COLUMN val2 NEW_VALUE x_sp_size NOPRINT
SELECT value val2
FROM v$parameter
WHERE name = 'shared_pool_size'
/

COLUMN val2 NEW_VALUE x_sp_used NOPRINT
SELECT SUM(sharable_mem + persistent_mem + runtime_mem) val2
FROM v$sqlarea
/

COLUMN val2 NEW_VALUE x_sp_used_shr NOPRINT
COLUMN val3 NEW_VALUE x_sp_used_per NOPRINT
COLUMN val4 NEW_VALUE x_sp_used_run NOPRINT
COLUMN val5 NEW_VALUE x_sp_no_stmts NOPRINT
SELECT
    SUM(sharable_mem) val2,
    SUM(persistent_mem) val3,
    SUM(runtime_mem) val4,
    COUNT(*) val5
FROM v$sqlarea
/

COLUMN val2 NEW_VALUE x_sp_no_obj NOPRINT
SELECT COUNT(*) val2 FROM v$db_object_cache 
/

COLUMN val2 NEW_VALUE x_sp_avail NOPRINT
SELECT &x_sp_size - &x_sp_used val2 FROM DUAL
/

COLUMN val2 NEW_VALUE x_sp_no_kept_chks NOPRINT
COLUMN val3 NEW_VALUE x_sp_sz_kept_chks NOPRINT
SELECT
    DECODE(COUNT(*), '', 0, COUNT(*)) val2,
    DECODE(SUM(sharable_mem), '', 0, SUM(sharable_mem)) val3
FROM v$db_object_cache
WHERE kept = 'YES'
/

COLUMN val2 NEW_VALUE x_sp_no_pins NOPRINT
SELECT COUNT(*) val2
FROM v$session a, v$sqltext b
WHERE a.sql_address || a.sql_hash_value = b.address || b.hash_value
/

COLUMN val2 NEW_VALUE x_sp_sz_pins NOPRINT
SELECT SUM(sharable_mem + persistent_mem + runtime_mem) val2
FROM v$session a, v$sqltext b, v$sqlarea c
WHERE a.sql_address || a.sql_hash_value = b.address || b.hash_value
AND b.address || b.hash_value = c.address || c.hash_value
/

@_TITLE 'LIBRARY CACHE SUMMARY'
SET HEADING OFF

SELECT
    'Size:                                   ' || &x_sp_size         || &CR ||
    'Used (total):                           ' || &x_sp_used         || &CR || 
    '     Sharable:                          ' || &x_sp_used_shr     || &CR ||
    '     Persistent:                        ' || &x_sp_used_per     || &CR ||
    '     Runtime:                           ' || &x_sp_used_run     || &CR ||
    'Available:                              ' || &x_sp_avail        || &CR ||
    'Number of SQL statements:               ' || &x_sp_no_stmts     || &CR ||
    'Number of programatic constructs:       ' || &x_sp_no_obj       || &CR ||
    'Kept programatic construct chunks:      ' || &x_sp_no_kept_chks || &CR ||
    'Kept programatic construct chunks size: ' || &x_sp_sz_kept_chks || &CR ||
    'Pinned statements:                      ' || &x_sp_no_pins      || &CR ||
    'Pinned statements size:                 ' || &x_sp_sz_pins      || &CR 
FROM DUAL
/

@_END
