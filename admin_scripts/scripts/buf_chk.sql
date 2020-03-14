REM
REM  Report that displays the database block buffer cache summary
REM 
REM  NOTES:
REM    1. The script should be executed by SYS.
REM    2. The system script CATPARR.SQL must be executed before.
REM

@_BEGIN
@_TITLE "BUFFER CACHE SUMMARY"
COLUMN status FORMAT A12

SELECT 
    DECODE(state, 
        0, 'Free', 
        1, 'Modified',
        2, 'Not Modified',
        3, 'Being Read',
           'Other') Status, 
    COUNT(*) Buffers
FROM
    sys.x$bh 
GROUP BY 
    state
/
@_END
	
