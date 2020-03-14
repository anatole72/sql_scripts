REM Author: Mark Gurry

@_BEGIN

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
PROMPT The third query lists how many times each object has been executed.
PROMPT 
PROMPT Oracle has provided a procedure which is stored in $ORACLE_HOME/rdbms/admin
PROMPT called dbmspool.sql. The SQL program produces 3 procedures. A procedure
PROMPT called KEEP (i.e. DBMS_SHARED_POOL.KEEP) can be run to pin a procedure in
PROMPT memory to ensure that it will not have to be re-loaded.    
PROMPT 
PROMPT Oracle 7.1.6 offers 2 new parameters that allow space to be reserved for
PROMPT procedures/packages above a selected size. This gives greater control 
PROMPT over the avoidance of fragmentation in the SHARED POOL. See the parameters 
PROMPT SHARED_POOL_RESERVED_SIZE and SHARED_POOL_RESERVED_MIN_ALLOC.
PROMPT 
PROMPT They are listed later in this report. 
PROMPT 

SET HEADING OFF
COLUMN name         FORMAT A51
COLUMN sharable_mem FORMAT 99,999,999
COLUMN executions   FORMAT 999,999,999
COLUMN "Pinned"     FORMAT A14;

@_TITLE 'Executions of Objects in Shared Pool'
SELECT  
    owner || '.' || name || ' - ' || type name, 
    executions , 
    DECODE(SUBSTR(kept, 1, 1), 'Y', '    ', '<<< Not Pinned') "Pinned"
FROM 
    v$db_object_cache
WHERE 
    executions > 100
    AND type IN ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
ORDER BY 
    executions DESC
/

@_TITLE 'Loads into Shared Pool'
select
    owner || '.' || name || ' - ' || type name, 
    loads, 
    sharable_mem 
FROM 
    v$db_object_cache
WHERE 
    loads > 3 
    AND type IN ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
ORDER BY 
    loads DESC
/

@_TITLE 'Objects that are KEPT'
SELECT 
    owner || '.' || name || ' - ' || type name, 
    kept
FROM 
    v$db_object_cache
WHERE 
    kept LIKE 'Y%'
ORDER BY 
    owner, name
/

@_TITLE 'Memory Usage of Shared Pool'
select
    owner || '.' || name || ' - ' || type name, 
    sharable_mem 
FROM 
    v$db_object_cache
WHERE 
    sharable_mem > 10000
    AND type IN ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
ORDER BY 
    sharable_mem DESC
/

@_END

