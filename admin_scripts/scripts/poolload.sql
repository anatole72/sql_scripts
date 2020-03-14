REM
REM  Shared pool load level
REM

@_BEGIN
@_TITLE "Shared pool load level"
SELECT 
    SUM(loads) loads,
    SUM(executions) execs,  
    ROUND((SUM(loads) / SUM(executions)) * 100, 4) "Load %"
FROM   
    sys.v_$db_object_cache
/
@_END	
