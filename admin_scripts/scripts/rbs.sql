REM
REM  Rollback segments general information
REM

@_BEGIN
@_TITLE 'ROLLBACK SEGMENTS'

COLUMN rollback_seg FORMAT A19      HEADING 'Rollback|Segment'
COLUMN tablespace   FORMAT A20      HEADING 'Segment|Tablespace'
COLUMN seg_size     FORMAT 99,999   HEADING 'Size(K)'
COLUMN ext_size     FORMAT 999      HEADING 'Ext|Size'
COLUMN extents      FORMAT 999      HEADING 'Exts'
COLUMN min          FORMAT 99       HEADING 'Min|Ext'
COLUMN max          FORMAT 999      HEADING 'Max|Ext'
COLUMN type         FORMAT A3       HEADING 'Typ' TRUNCATE
COLUMN status       FORMAT A3       HEADING 'Sta' TRUNCATE
COLUMN active       FORMAT A3       HEADING 'Act' TRUNCATE

SELECT 
    r.segment_name rollback_seg,
    r.tablespace_name tablespace,
    s.bytes / 1024 seg_size,
    r.initial_extent / 1024 ext_size,
    s.extents,
    r.min_extents min, 
    r.max_extents max, 
    r.status, 
    DECODE(r.owner, 'SYS', 'PRIVATE', r.owner) type,
    DECODE(NVL(rs.xacts, -1), -1, 'N/A', 0, 'NO', 'YES') active
FROM 
    dba_rollback_segs r,
    dba_segments s,
    v$rollstat rs,
    v$rollname rn
WHERE
    s.segment_name = r.segment_name
    AND s.segment_type = 'ROLLBACK'
    AND rn.name(+) = r.segment_name
    AND rs.usn(+) = rn.usn
ORDER BY
    r.segment_name
;
@_END
