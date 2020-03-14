REM
REM  Recommended shared pool size
REM  Author: Mark Gurry
REM

@_BEGIN

@_HIDE
COLUMN value NEW_VALUE min_alloc NOPRINT
SELECT value
FROM   v$parameter
WHERE name = 'shared_pool_reserved_min_alloc';

@_SET
PROMPT
PROMPT The following script calculates that you have set your
PROMPT SHARED_POOL_RESERVED_MIN_ALLOC to &min_alloc..

SELECT SUM(sharable_mem) CACHE_MEMORY
FROM   v$db_object_cache
WHERE  sharable_mem > &min_alloc;

PROMPT 
PROMPT This is the total memory of packages, procedures, triggers, views, 
PROMPT functions and other objects stored in the shared pool.

SELECT SUM(sharable_mem) SQL_MEMORY
FROM   v$sqlarea
WHERE  sharable_mem > &min_alloc;

PROMPT 
PROMPT This output is the amount of storage required for SQL. If you add the
PROMPT two values together, you have an approximate sizing for the 
PROMPT SHARED_POOL_RESERVED size. It is best to add on some contingency, 
PROMPT say 40% for factors such as dynamic SQL which is not counted in the 
PROMPT second query, and all statements not current running. 
PROMPT
PROMPT The same methods can be used to calculate the total shared pool size.
PROMPT You simply take away the WHERE SHARABLE_MEM > &MIN_ALLOC: 

SELECT SUM(sharable_mem) TOTAL_CACHE_MEMORY
FROM   v$db_object_cache;
SELECT SUM(sharable_mem) TOTAL_SQL_MEMORY
FROM   v$sqlarea;

PROMPT
PROMPT When you are estimating the total shared pool size, you have to also 
PROMPT take into account user cursors, which also use memory. You need about 
PROMPT 250 bytes of shared pool memory per user for each cursor that the user
PROMPT has open. To obtain the total cursor usage, run the following query or 
PROMPT you can get the figure from the library cache from the V$SGASTAT table 
PROMPT which amounts to the same thing. 

SELECT SUM(250 * users_opening) CURSORS_MEMORY
FROM   v$sqlarea;

PROMPT
PROMPT The SHARED_POOL_SIZE must also include memory for the dictionary cache 
PROMPT (usually around 4 Meg) and a collection of areas required to compile 
PROMPT database objects and other miscellaneous areas shown in the V$SGASTAT.

@_END
