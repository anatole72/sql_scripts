REM
REM  List segments grouped by segment type
REM  Author: Mark Lang, 1998
REM 

PROMPT
PROMPT SEGMENTS GROUPED BY SEGMENT TYPE
PROMPT
ACCEPT own PROMPT "Segment owner like (ENTER for all): "
ACCEPT nam PROMPT "Segment name like (ENTER for all): "
ACCEPT typ PROMPT "Segment type like (ENTER for all): "
ACCEPT tsp PROMPT "Segment tablespace like (ENTER for all): "

@_BEGIN
@_TITLE "SEGMENTS GROUPED BY SEGMENT TYPE"

COLUMN owner            FORMAT A15          HEADING "OWNER"
COLUMN segment_type     FORMAT A10          HEADING "TYPE"
COLUMN tablespace_name  FORMAT A12          HEADING "TABLESPACE"
COLUMN cntsegs          FORMAT 9990         HEADING "SEGS"
COLUMN avgexts          FORMAT 90.9         HEADING "AVGEXT"
COLUMN maxexts          FORMAT 9990         HEADING "MAXEXT"
COLUMN sumblks          FORMAT 999,990      HEADING "BLOCKS"
COLUMN sumbyts          FORMAT 9,999,990    HEADING "KBYTES"
BREAK ON owner SKIP 1 ON segment_type 

SELECT
    s.owner,
    s.segment_type,
    s.tablespace_name,
    count(*) cntsegs,
    avg(s.extents) avgexts,
    max(s.extents) maxexts,
    sum(s.blocks) sumblks,
    sum(s.bytes / 1024) sumbyts
FROM
    dba_segments s
WHERE
    s.owner LIKE NVL(UPPER('&&own'), '%')
    AND s.segment_name LIKE NVL(UPPER('&&nam'), '%')
    AND s.segment_type LIKE NVL(UPPER('&&typ'), '%')
    AND s.tablespace_name LIKE NVL(UPPER('&&tsp'), '%')
GROUP BY
    s.owner,
    s.segment_type,
    s.tablespace_name
ORDER BY
    s.owner,
    s.segment_type,
    s.tablespace_name
;

UNDEFINE own nam typ tsp

@_END
