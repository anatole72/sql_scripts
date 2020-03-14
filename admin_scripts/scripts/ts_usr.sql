REM
REM  Owner-to-tablespace location map
REM

@_BEGIN
@_TITLE "OWNER-TO-TABLESPACE MAP"

COLUMN tablespace_name FORMAT A28
BREAK ON tablespace_name SKIP 1 ON owner

SELECT 
   tablespace_name, 
   owner, 
   COUNT(segment_name) segments,
   SUM (bytes) / 1024 kbytes 
FROM 
   dba_segments 
GROUP BY
   tablespace_name,
   owner
ORDER BY 
   tablespace_name, 
   owner
;

@_END

