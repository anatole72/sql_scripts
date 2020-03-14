@_BEGIN

PROMPT
PROMPT This script shows the library latch contention. The usual cause of 
PROMPT the problem is to have the library latch set too small.

SELECT 
    SUBSTR(name, 1, 25) name, 
    gets, 
    misses,
    immediate_gets, 
    immediate_misses 
FROM 
    v$latch 
WHERE  
    (misses > 0 OR immediate_misses > 0)
    AND name LIKE 'library cach%'
;
@_END
