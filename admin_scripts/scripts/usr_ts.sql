REM
REM Tablespace-to-owner location map
REM

@_BEGIN
@_TITLE "TABLESPACE-TO-OWNER MAP"

COLUMN Tablespace_Name FORMAT A28
BREAK ON owner SKIP 1 ON Tablespace_Nmae

SELECT 
   owner, 
   tablespace_name, 
   COUNT(segment_name) segments,
   SUM (bytes) / 1024 kbytes 
FROM 
   dba_segments 
GROUP BY
   owner,
   tablespace_name
ORDER BY 
   owner,
   tablespace_name 
;

@_END

