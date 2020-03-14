REM
REM  Database usage by user and tablespace
REM  Author: G. Godart-Brown, 1991
REM

@_BEGIN
@_TITLE 'DATABASE USAGE BY USER AND TABLESPACE'

COLUMN K    FORMAT 999,999,999  HEADING 'Used(K)'
COLUMN ow   FORMAT A30          HEADING 'Owner'
COLUMN ta   FORMAT A30          HEADING 'Tablespace'
BREAK ON ow 

SELECT  
    us.name ow,
    ts.name ta,
    SUM(seg.blocks * ts.blocksize) / 1024 K
FROM    
    sys.ts$ ts,
    sys.user$ us,
    sys.seg$ seg
WHERE   
    seg.user# = us.user#
    and ts.ts# = seg.ts#
GROUP BY 
    us.name,
    ts.name
/
@_END
