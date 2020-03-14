REM
REM  Create list of all database rollback segments
REM  and their storage defaults
REM

@_BEGIN
@_TITLE 'ROLLBACK STORAGE DEFAULTS'

COLUMN rollback_seg FORMAT A19      HEADING 'Rollback|Segment'
COLUMN tablespace   FORMAT A20      HEADING 'Segment|Tablespace'
COLUMN init         FORMAT 9,999    HEADING 'Init|Ext(K)'
COLUMN next         FORMAT 9,999    HEADING 'Next|Ext(K)'
COLUMN min          FORMAT 99       HEADING 'Min|Ext'
COLUMN max          FORMAT 999      HEADING 'Max|Ext'
COLUMN type                         HEADING 'Rbs|Type'
COLUMN status       FORMAT A7       HEADING 'Rbs|Status' TRUNCATE

SELECT 
    segment_name rollback_seg,
    tablespace_name tablespace, 
    initial_extent / 1024 init,
    next_extent / 1024 next, 
    min_extents min, 
    max_extents max, 
    status, 
    DECODE(owner, 'SYS', 'PRIVATE', owner) type
FROM 
    dba_rollback_segs
ORDER BY
    segment_name
;
@_END
