REM
REM  Generate a report of active rollbacks
REM

@_BEGIN
@_TITLE "Rollback Segments in Use"

COLUMN  name    FORMAT A26          HEADING "Rollback Segment"
COLUMN  sid     FORMAT 9999999999   HEADING "Oracle PID"
COLUMN  spid    FORMAT 9999999999  	HEADING "Sys PID"
COLUMN username                     HEADING Username

SELECT 
    r.name,
    l.sid,
    p.spid,
    s.username 
FROM 
    v$lock l, 
    v$process p, 
    v$rollname r, 
    v$session s
WHERE  
    l.sid = p.pid(+)
    AND s.sid(+) = l.sid
    AND TRUNC (l.id1(+) / 65536) = r.usn
    AND l.type(+) = 'TX'
    AND l.lmode(+) = 6
ORDER BY 
    r.name
;
@_END
