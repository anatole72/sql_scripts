REM
REM  Summary information about free space in tablespaces
REM

@_BEGIN
@_TITLE "FREE SPACE IN TABLESPACES"

COLUMN ts   HEADING "Tablespace Name"   FORMAT A25
COLUMN num  HEADING "Free|Exts"         FORMAT 9999
COLUMN dead HEADING "Dead|Exts"         FORMAT 999
COLUMN min  HEADING "Min Free|(Kbytes)" FORMAT 9999999999
COLUMN max  HEADING "Max Free|(Kbytes)" FORMAT 9999999999
COLUMN sum  HEADING "Sum Free|(Kbytes)" FORMAT 9999999999
COLUMN free HEADING "% Free"            FORMAT 999.9

SELECT 
   f.tablespace_name ts, 
   COUNT(f.bytes) num,
   SUM(DECODE(SIGN(f.bytes - 5), -1, f.bytes, 0))  dead,
   MIN(f.bytes) / 1024 min,
   MAX(f.bytes) / 1024 max, 
   SUM(f.bytes) / 1024 sum,
   ROUND(SUM(f.bytes) / d.bytes, 3) * 100 free
FROM
   dba_free_space f,
   dba_data_files d
WHERE 
   f.file_id = d.file_id
GROUP BY 
   f.tablespace_name, 
   d.bytes
;

@_END

