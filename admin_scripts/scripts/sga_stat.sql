REM
REM  This script lists key SGA memory usage
REM

@_SET
@_HIDE

COLUMN sum_bytes NEW_VALUE divide_by NOPRINT
SELECT SUM(value) sum_bytes FROM sys.v_$sga;

@_BEGIN
@_TITLE 'SGA Memory Usage (Main)'

COLUMN percent FORMAT 999.99 HEADING '% OF TOTAL'
SELECT 
    name,
    bytes,
    TO_CHAR (bytes / 1024, '999,999.99') kbytes,
    TO_CHAR (bytes / 1024 / 1024, '9,999.99') mbytes,
    bytes / &divide_by * 100  percent
FROM 
    v$sgastat
WHERE 
    name IN (
        'free memory', 
        'db_block_buffers', 
        'log_buffer',
        'dictionary cache', 
        'sql area', 
        'library cache'
    )
ORDER BY
    name
; 

@_TITLE 'SGA Memory Usage (Other)'
SELECT 
    name,
    bytes,
    TO_CHAR (bytes / 1024, '999,999.99') kbytes,
    TO_CHAR (bytes / 1024 / 1024, '9,999.99') mbytes,
    bytes / &divide_by * 100  percent
FROM 
    v$sgastat
WHERE 
    name NOT IN (
        'free memory', 
        'db_block_buffers', 
        'log_buffer',
        'dictionary cache', 
        'sql area', 
        'library cache'
    )
ORDER BY
    name
; 

UNDEFINE divide_by 
@_END
