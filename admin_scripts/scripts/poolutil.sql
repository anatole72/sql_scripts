REM
REM  Shared Pool Estimation
REM
REM  Estimates shared pool utilization based on current database usage. 
REM  This should be run during peak operation, after all stored objects 
REM  i.e. packages, views have been loaded.
REM
REM  If running MTS uncomment the mts calculation and output
REM  commands.
REM

@_BEGIN
SET SERVEROUTPUT ON;

DECLARE

    object_mem      NUMBER;
    shared_sql      NUMBER;
    cursor_mem      NUMBER;
    mts_mem         NUMBER;
    used_pool_size  NUMBER;
    free_mem        NUMBER;
    pool_size       VARCHAR2(512); -- same as V$PARAMETER.VALUE

BEGIN

    -- Stored objects (packages, views)
    SELECT SUM(sharable_mem) INTO object_mem FROM v$db_object_cache;

    -- Shared SQL -- need to have additional memory if dynamic SQL used
    SELECT SUM(sharable_mem) INTO shared_sql FROM v$sqlarea;

    -- User Cursor Usage -- run this during peak usage
    -- (assumes 250 bytes per open cursor, for each concurrent user)
    SELECT SUM(250 * users_opening) INTO cursor_mem FROM v$sqlarea;

    -- For a test system -- get usage for one user, multiply by # users
    -- SELECT (250 * value) bytes_per_user 
    -- FROM v$sesstat s, v$statname n
    -- WHERE s.statistic# = n.statistic#
    -- AND n.name = 'opened cursors current'
    -- AND s.sid = 25;  -- where 25 is the sid of the process

    -- MTS memory needed to hold session information for shared server users.
    -- This query computes a total for all currently logged on users (run
    -- multiply by # users)
    SELECT SUM(value) 
    INTO mts_mem 
    FROM v$sesstat s, v$statname n
    WHERE s.statistic# = n.statistic#
    AND n.name = 'session uga memory max';

    -- Free (unused) memory in the SGA: gives an indication of how much memory
    -- is being wasted out of the total allocated
    SELECT bytes 
    INTO free_mem 
    FROM v$sgastat
    WHERE name = 'free memory';

    -- For non-MTS add up object, shared sql, cursors and 20% overhead
    used_pool_size := ROUND(1.2 * (object_mem + shared_sql + cursor_mem));

    -- For MTS mts contribution needs to be included (comment out previous line)
    -- used_pool_size := ROUND(1.2 * (object_mem + shared_sql + cursor_mem + mts_mem));

    SELECT value 
    INTO pool_size 
    FROM v$parameter 
    WHERE name = 'shared_pool_size';

    --
    -- DISPLAY RESULTS
    --
    DBMS_OUTPUT.PUT_LINE(
        'SHARED POOL UTILIZATION');
    DBMS_OUTPUT.PUT_LINE(
        '-----------------------');
    DBMS_OUTPUT.PUT_LINE(
        'Stored object memory: ' || TO_CHAR(object_mem) || ' bytes');
    DBMS_OUTPUT.PUT_LINE(
        'Shared SQL memory: ' || TO_CHAR(shared_sql) || ' bytes');
    DBMS_OUTPUT.PUT_LINE(
        'Cursors memory: ' || TO_CHAR(cursor_mem) || ' bytes');
--  DBMS_OUTPUT.PUT_LINE(
--      'MTS session memory: ' || TO_CHAR(mts_mem) || ' bytes');
    DBMS_OUTPUT.PUT_LINE(
        'Free memory: ' || TO_CHAR(free_mem) || ' bytes ' || '(' ||
        TO_CHAR(ROUND(free_mem / 1024 / 1024, 2)) || 'MB)');
    DBMS_OUTPUT.PUT_LINE(
        'Shared pool utilization (total): ' || 
        TO_CHAR(used_pool_size) || ' bytes ' || '(' || 
        TO_CHAR(ROUND(used_pool_size / 1024 / 1024, 2)) || 'MB)');
    DBMS_OUTPUT.PUT_LINE(
        'Shared pool allocation (actual): ' || 
        pool_size || ' bytes ' || '(' ||
        TO_CHAR(ROUND(pool_size / 1024 / 1024, 2)) || 'MB)');
    DBMS_OUTPUT.PUT_LINE(
        'Percentage Utilized: ' || 
        TO_CHAR(ROUND(used_pool_size / pool_size * 100)) || '%');
END;
/
@_END

