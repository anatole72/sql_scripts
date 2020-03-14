REM
REM  This script lists information on who is accessing the various 
REM  rollbacks as of NOW!
REM
REM  Author: Mark Gurry
REM

@_BEGIN
@_TITLE "Current Rollback Segment Usage"

COLUMN name HEADING "Rollback Segment"      FORMAT A19;
COLUMN spid HEADING "Process"               FORMAT A7; 
COLUMN sess HEADING "Oracle User Session"   FORMAT A20;
COLUMN text HEADING "SQL Statement"         FORMAT A30 WORD_WRAP;

SELECT 
    r.name,
    p.spid, 
    s.username || '(' || l.sid || ')' sess,
    sq.sql_text text
FROM 
    v$sqlarea sq, 
    v$lock l, 
    v$process p, 
    v$session s, 
    v$rollname r
WHERE 
    l.sid = p.pid(+)
    AND s.sid(+) = l.sid
    AND TRUNC(l.id1(+) / 65536) = r.usn
    AND l.type(+) = 'TX'
    AND l.lmode(+) = 6
    AND s.sql_address = sq.address
    AND s.sql_hash_value = sq.hash_value
ORDER BY 
    r.name
/
@_END

