REM
REM This script lists tablespace disk storage information
REM

REM
REM Calculate database block size
REM
SET TERMOUT OFF
SET PAGESIZE 0
COLUMN value NOPRINT NEW_VALUE block_size
SELECT value 
FROM v$parameter
WHERE name = 'db_block_size';

@_BEGIN
@_TITLE 'TABLESPACE STORAGE INFORMATION'

SELECT 
    SUBSTR(d.tablespace_name, 1, 27) TABLESPACE,
    d.file_id,
    d.bytes / 1024 / 1024 TOTAL_MB,
    d.bytes / &block_size ORA_BLOCKS,
    NVL(SUM(e.blocks), 0) TOTAL_USED,
    NVL(ROUND(SUM(e.blocks) / (d.bytes / &block_size), 4) * 100, 0)  PCT_USED
FROM  
    sys.dba_extents e, 
    sys.dba_data_files d
WHERE 
    d.file_id = e.file_id (+)
GROUP BY 
    d.tablespace_name, 
    d.file_id, 
    d.bytes
/
UNDEFINE block_size
@_END
