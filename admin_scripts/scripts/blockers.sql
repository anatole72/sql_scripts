REM
REM  This script shows who is holding a lock that other people are
REM  waiting for and who the waiters are.
REM
REM  Author: Mark Gurry
REM

@_BEGIN
@_TITLE 'BLOCKERS AND WAITERS'

COLUMN object       FORMAT A29  HEADING Object
COLUMN holder       FORMAT A14  HEADING Blocker
COLUMN waiter       FORMAT A14  HEADING Waiter
COLUMN lock_type    FORMAT A19  HEADING "Lock Type"

SELECT DISTINCT 
    o.owner || '.' || o.object_name object, 
    sh.username || '(' || sh.sid || ')' holder, 
    sw.username || '(' || sw.sid || ')' waiter,
    DECODE(lh.lmode, 
        1, 'null', 
        2, 'row share', 
        3, 'row exclusive', 
        4, 'share', 
        5, 'share row exclusive' , 
        6, 'exclusive') lock_type
FROM 
    all_objects o, 
    v$session sw, 
    v$lock lw, 
    v$session sh, 
    v$lock lh
WHERE 
    lh.id1 = o.object_id
    AND lh.id1 = lw.id1
    AND sh.sid = lh.sid
    AND sw.sid = lw.sid
    AND sh.lockwait IS NULL
    AND sw.lockwait IS NOT NULL
    AND lh.type = 'TM'
    AND lw.type = 'TM'
/
@_END
