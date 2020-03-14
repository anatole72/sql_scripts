REM
REM  Reports index fragmentation statistics 
REM
REM  Provides information critical in determining whether an index is a
REM  candidate for rebuilding. An index is a candidate for rebuilding
REM  when a relatively high number of index leaf row deletes have occured.  
REM
REM  Authors:  Peter Utzig, Craig Shallahamer , Oracle US   
REM

@_BEGIN
SET PAGESIZE 0

PROMPT
PROMPT INDEX FRAGMENTATION STATISTICS
PROMPT

ACCEPT ownr PROMPT "Index owner: "
ACCEPT name PROMPT "Index name: "
PROMPT

COLUMN lf_blk_rows  NEWLINE  
COLUMN del_lf_rows  NEWLINE  
COLUMN ibadness     NEWLINE   
  
ANALYZE INDEX &ownr..&name VALIDATE STRUCTURE;  
  
SELECT
    'Rows deleted:  '
        || TO_CHAR(del_lf_rows, 'fm999,999,990') del_lf_rows,  
    'Rows in use:   '
        || TO_CHAR(lf_rows - del_lf_rows, 'fm999,999,990') lf_blk_rows,   
    'Index badness: '
        || TO_CHAR(del_lf_rows / (lf_rows + 0.00001) * 100, 'fm990.0')
        || '%' ibadness  
FROM  
    index_stats  
/  
  
UNDEFINE ownr  
UNDEFINE name  

@_END
