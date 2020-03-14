REM
REM  Find packages without body
REM

@_BEGIN
@_TITLE "PACKAGES WITHOUT BODY"

COLUMN owner       FORMAT A30 HEADING "Owner"
COLUMN object_name FORMAT A30 HEADING "Packages"

SELECT 
    owner,
    object_name 
FROM 
    dba_objects
WHERE 
    object_type = 'PACKAGE'
MINUS
SELECT 
    owner,
    object_name 
FROM 
    dba_objects
WHERE 
    object_type = 'PACKAGE BODY'
ORDER BY
    owner,
    object_name
/
@_END
