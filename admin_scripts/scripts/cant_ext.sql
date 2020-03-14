REM
REM  The next output is not strictly tuning, but it gives you a list of all    
REM  database objects that will fail when they attempt to throw their next extent
REM  due to a lack of a free extent that is of sufficient size in the same
REM  tablespace as where the object resides. If the problem happens to occur 
REM  on a dictionary table, the whole database can potentially freeze, which I
REM  suppose is response related. 
REM
REM  Author: Mark Gurry
REM

@_BEGIN
@_TITLE 'NEXT EXTENT BLOWUP REPORT'

COLUMN owner FORMAT A10;
COLUMN segment FORMAT A40;
COLUMN segment_type HEADING "TYPE" FORMAT A10;
COLUMN tablespace_name HEADING "TABLESPACE" FORMAT A14;
COLUMN next_extent FORMAT 999,999,999;

SELECT 
    seg.owner || '.' || seg.segment_name segment,
    seg.segment_type, seg.tablespace_name,
    t.next_extent
FROM 
    sys.dba_segments seg,
    sys.dba_tables t
WHERE (
    seg.segment_type = 'TABLE'
    AND seg.segment_name = t.table_name
    AND seg.owner = t.owner
    AND NOT EXISTS (
         SELECT tablespace_name
         FROM dba_free_space free
         WHERE free.tablespace_name = t.tablespace_name
         AND bytes >= t.next_extent
    )
)
UNION
SELECT 
    seg.owner || '.' || seg.segment_name segment,
    seg.segment_type, seg.tablespace_name,
    DECODE (
        seg.segment_type,
        'CLUSTER',  c.next_extent
    )
FROM 
    sys.dba_segments seg,
    sys.dba_clusters c 
WHERE (
    seg.segment_type = 'CLUSTER'
    AND seg.segment_name = c.cluster_name
    AND seg.owner = c.owner
    AND NOT EXISTS (
        SELECT tablespace_name
        FROM dba_free_space free
        WHERE free.tablespace_name = c.tablespace_name
        AND bytes >= c.next_extent     
    )
)
UNION
SELECT 
    seg.owner || '.' || seg.segment_name segment,
    seg.segment_type, seg.tablespace_name,
    DECODE (
        seg.segment_type,
        'INDEX', i.next_extent 
    )
FROM 
    sys.dba_segments seg,
    sys.dba_indexes i
WHERE (
    seg.segment_type = 'INDEX'
    AND seg.segment_name = i.index_name
    AND seg.owner = i.owner
    AND NOT EXISTS (
        SELECT tablespace_name
        FROM dba_free_space free
        WHERE free.tablespace_name = i.tablespace_name
        AND bytes >= i.next_extent     
    )
)
UNION
SELECT 
    seg.owner || '.' || seg.segment_name segment,
    seg.segment_type, seg.tablespace_name,
    DECODE (
        seg.segment_type,
        'ROLLBACK', r.next_extent
    )
FROM 
    sys.dba_segments seg,
    sys.dba_rollback_segs r
WHERE (
    seg.segment_type = 'ROLLBACK'
    AND seg.segment_name = r.segment_name
    AND seg.owner        = r.owner
    AND NOT EXISTS (
        SELECT tablespace_name
        FROM dba_free_space free
        WHERE free.tablespace_name = r.tablespace_name
        AND bytes >= r.next_extent     
    )
) 
/

@_TITLE 'Segments that Are Sitting on the Maximum Extents Allowable'
SELECT 
    s.owner || '.' || s.segment_name segment,
    e.segment_type, 
    COUNT(*), 
    AVG(max_extents)
FROM 
    dba_extents e , 
    dba_segments s
WHERE  
    e.segment_name = s.segment_name
    AND e.owner = s.owner 
GROUP BY  
    s.owner || '.' || s.segment_name,
    e.segment_type
HAVING 
    COUNT(*) = AVG(max_extents)                                       
/

@_END


