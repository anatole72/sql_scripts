REM
REM   Show all users that have active transactions per Rollback Segment
REM   that they are writing to.
REM

@_BEGIN

COLUMN name     FORMAT A20 HEADING "Rollback Segment"
COLUMN sid      FORMAT 990 HEADING "Session|ID"
COLUMN username FORMAT A16 HEADING "Oracle|Username"
COLUMN osuser   FORMAT A16 HEADING "O/S|Username"
COLUMN program  FORMAT A16 HEADING "Program"

@_TITLE 'Rollback Segment Usage by Active Transactions'

SELECT 
    r.name, 
    l.sid, 
    s.username, 
    s.osuser, 
    s.program
FROM 
    v$rollname r, 
    v$session s, 
    v$lock l
WHERE 
    r.usn = TRUNC(l.id1 / 65536)
    AND l.sid = s.sid
    AND l.type = 'TX'
ORDER BY 
    r.name
;
@_END
