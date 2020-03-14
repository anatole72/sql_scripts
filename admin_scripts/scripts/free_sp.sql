REM
REM  Provide information on free space in the database
REM

@_BEGIN
@_HIDE

CREATE TABLE temp$free_space(
    tablespace, 
    file_id, 
    pieces, 
    free_bytes, 
    free_blocks, 
    largest_bytes,
    largest_blks,
    fsfi) 
AS
SELECT 
    tablespace_name, 
    file_id, 
    COUNT(*),
    SUM(bytes), 
    SUM(blocks),
    MAX(bytes), 
    MAX(blocks),
    SQRT(MAX(blocks) / SUM(blocks)) * (100 / SQRT(SQRT(COUNT(blocks)))) 
FROM 
    sys.dba_free_space
GROUP BY 
    tablespace_name, 
    file_id
;

@_SET
@_WTITLE "DATABASE FREE SPACE REPORT"

COLUMN tablespace       HEADING Tablespace          FORMAT A30
COLUMN files            HEADING '#Files'            FORMAT 9,999
COLUMN pieces           HEADING Frags               FORMAT 9,999
COLUMN free_bytes       HEADING 'Free|Bytes'        FORMAT 9,999,999,999
COLUMN free_blocks      HEADING 'Free|Blocks'       FORMAT 999,999
COLUMN largest_bytes    HEADING 'Biggest|Bytes'     FORMAT 9,999,999,999
COLUMN largest_blocks   HEADING 'Biggest|Blocks'    FORMAT 999,999
COLUMN ratio            HEADING 'Biggest|Percent'   FORMAT 999.99
COLUMN average_fsfi	    HEADING 'Average|FSFI'		FORMAT 999.999

SELECT 
    tablespace,
    COUNT(*) files,
    SUM(pieces) pieces,
    SUM(free_bytes) free_bytes,
    SUM(free_blocks) free_blocks,
    SUM(largest_bytes) largest_bytes,
    SUM(largest_blks) largest_blocks, 
    SUM(largest_bytes) / SUM(free_bytes) * 100 ratio,
    SUM(fsfi) / COUNT(*) average_fsfi 
FROM 
    temp$free_space
GROUP BY 
    tablespace
;

@_HIDE
DROP TABLE temp$free_space;
@_SET
@_END
