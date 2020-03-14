REM
REM This script lists the reserved pool setting for the shared pool
REM

@_BEGIN
@_TITLE 'The Reserved Pool Settings for the Shared Pool Area'

SELECT 
    SUBSTR(name, 1, 32) "Parameter", 
    SUBSTR(value, 1, 12) "Setting"
FROM 
    v$parameter
WHERE 
    name LIKE '%reser%'
    OR name = 'shared_pool_size'
;
@_END
