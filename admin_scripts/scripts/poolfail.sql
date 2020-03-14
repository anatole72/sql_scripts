REM
REM This script informs you if the larger objects have failed to obtain
REM space in the part of the shared pool reserved for larger objects.
REM
REM Author: Mark Gurry
REM

@_BEGIN
@_TITLE 'Shared Pool Reserved Size Recommendation'

SET HEADING OFF
COLUMN nl FORMAT A60 NEWLINE

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

@_END
