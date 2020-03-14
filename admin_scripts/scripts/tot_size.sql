REM
REM  This script lists the size of stored objects (summaried by type)
REM 

@_BEGIN
@_TITLE "SIZES OF STORED OBJECTS (BY TYPE)"

COLUMN num_instances    HEADING "Num"           FORMAT 999
COLUMN type             HEADING "Object Type"   FORMAT A12
COLUMN source_size      HEADING "Source"        FORMAT 99,999,999
COLUMN parsed_size      HEADING "Parsed"        FORMAT 99,999,999
COLUMN code_size        HEADING "Code"          FORMAT 99,999,999
COLUMN error_size       HEADING "Errors"        FORMAT 999,999
COLUMN size_required    HEADING "Total"         FORMAT 999,999,999

SELECT 
    COUNT(name) num_instances,
    type,
    SUM(source_size) source_size,
    SUM(parsed_size) parsed_size,
    SUM(code_size) code_size,
    SUM(error_size) error_size,
    SUM(source_size)
        + SUM(parsed_size)
        + SUM(code_size)
        + SUM(error_size) size_required
FROM 
    dba_object_size
GROUP BY 
    type
/

@_END
