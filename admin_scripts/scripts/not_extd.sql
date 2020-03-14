REM
REM  Report to list objects that will not be able to extent due to
REM  insufficient free space
REM
REM  Author:  Joseph  C. Trezzo
REM

PROMPT
PROMPT OBJECTS NOT ABLE TO EXTENT
PROMPT
ACCEPT ts PROMPT "Tablespace name like (ENTER for all): "

@_BEGIN
@_TITLE 'DATABASE OBJECTS NOT ABLE TO EXTENT'

COLUMN segment          FORMAT A40          HEADING "Segment"
COLUMN segment_type     FORMAT A10          HEADING "Type"
COLUMN tablespace_name  FORMAT A17          HEADING "Tablespace"
COLUMN next_extent      FORMAT 999,999,999  HEADING "Next|Extent"
BREAK ON tablespace_name SKIP 1

SELECT 
    s.tablespace_name,
    s.owner || '.' || s.segment_name segment,
    s.segment_type, 
    TO_CHAR((s.next_extent * (1 + DECODE(s.extents, 1, 0,
        s.pct_increase) / 100) / 1024), '999,999') || 'K' next_extent
FROM 
    dba_segments s
WHERE
    s.tablespace_name LIKE NVL(UPPER('&&ts'), '%')
    AND NOT EXISTS (
        SELECT 'x'
        FROM dba_free_space f
        WHERE f.tablespace_name = s.tablespace_name
        AND f.bytes >= (s.next_extent *
            (1 + DECODE(Extents, 1, 0, s.pct_increase) / 100))
        )
ORDER BY
    s.tablespace_name,
    s.owner || '.' || s.segment_name
/
@_END
