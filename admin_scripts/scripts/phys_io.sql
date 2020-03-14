REM
REM  The following script provides information on datafile reads 
REM  and writes.
REM
REM  Author: Mark Gurry
REM

@_SET
SET FEEDBACK OFF
SET TERMOUT OFF

DROP TABLE temp$trw;
CREATE TABLE temp$trw AS 
    SELECT 
        SUM(phyrds) phys_reads, 
        SUM(phywrts) phys_wrts
    FROM 
        v$filestat
    ;

@_BEGIN
@_TITLE 'I/O BY DATAFILE'

COLUMN name         FORMAT A37
COLUMN phyrds       FORMAT 999,999,999  HEADING "Physical|Reads"
COLUMN phywrts      FORMAT 999,999,999  HEADING "Physical|Writes"
COLUMN read_pct     FORMAT 999.99       HEADING "Read %"       
COLUMN write_pct    FORMAT 999.99       HEADING "Write %"       

SELECT 
    name, 
    phyrds, 
    phyrds * 100 / trw.phys_reads read_pct, 
    phywrts,  
    phywrts * 100 / trw.phys_wrts write_pct
FROM  
    temp$trw trw, 
    v$datafile df, 
    v$filestat fs 
WHERE 
    df.file# = fs.file# 
ORDER BY 
    phyrds + phywrts DESC
; 

DROP TABLE temp$trw;

@_END
