REM
REM  The following script lists user session cursor usage. The opened cursors
REM  figure should ideally be less than the INIT.ORA OPEN_CURSORS parameter.
REM
REM  Author: Mark Gurry
REM

@_HIDE
DROP TABLE temp$user_cursors;

CREATE TABLE temp$user_cursors AS
SELECT 
    ss.username || '(' || se.sid || ') ' "User Process", 
    SUM(DECODE(name, 'recursive calls', value)) "Recursive Calls", 
    SUM(DECODE(name, 'opened cursors cumulative', value)) "Opened Cursors", 
    SUM(DECODE(name, 'opened cursors current', value)) "Current Cursors"
FROM 
    v$session ss, 
    v$sesstat se, 
    v$statname sn
WHERE  
    se.statistic# = sn.statistic#
    AND (name LIKE '%opened cursors current%'
	        OR name LIKE '%recursive calls%'
            OR name LIKE '%opened cursors cumulative%')
    AND se.sid = ss.sid
    AND ss.username IS NOT NULL
GROUP BY 
    ss.username || '(' || se.sid || ') '
;

@_BEGIN
@_TITLE 'PER SESSION CURRENT CURSOR USAGE'

COLUMN "User Process"       FORMAT A32;
COLUMN "Recursive Calls"    FORMAT 999,999,999;
COLUMN "Opened Cursors"     FORMAT 99,999; 
COLUMN "Current Cursors"    FORMAT 99,999;

SELECT * 
FROM temp$user_cursors   
ORDER BY "Recursive Calls" DESC
; 

@_HIDE
DROP TABLE temp$user_cursors;
@_SET

@_END
