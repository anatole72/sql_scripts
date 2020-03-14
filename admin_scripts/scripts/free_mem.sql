REM
REM  Shared pool free memory
REM

@_BEGIN
@_TITLE "SHARED POOL FREE MEMORY"

SELECT 
    s.bytes "Free Bytes", 
    s.bytes / (1024 * 1024) "Free Bytes (Mb)", 
    p.value / (1024 * 1024) "Total Pool (Mb)",
    ROUND((s.bytes / p.value) * 100, 2) "% Free"
FROM   
    sys.v_$parameter p,
    sys.v_$sgastat s
WHERE  
    s.name = 'free memory'
    AND p.name = 'shared_pool_size'
/

@_END


	
