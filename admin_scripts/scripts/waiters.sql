REM 
REM  Report on sessions waiting for locks
REM
REM  NOTES: To execute the script you have to run CATBLOCK.SQL before
REM 

@_BEGIN
@_WTITLE 'Processes Waiting on Locks'
 
COLUMN busername        FORMAT A20  HEADING 'Holding|User'
COLUMN wusername        FORMAT A20  HEADING 'Waiting|User'
COLUMN mode_held        FORMAT A20  HEADING 'Mode|Held'
COLUMN mode_requested   FORMAT A20  HEADING 'Mode|Requested'
COLUMN lock_id1         FORMAT A10  HEADING 'Lock|ID1'
COLUMN lock_id2         FORMAT A10  HEADING 'Lock|ID2'
COLUMN type             FORMAT A25  HEADING 'Lock|Type'

SELECT 
    b.username || '(' || holding_session || ')' busername, 
    a.username || '(' || waiting_session || ')'wusername, 
    c.lock_type type, 
    mode_held, 
    mode_requested,
    lock_id1, 
    lock_id2 
FROM
    sys.v_$session b, 
    sys.dba_waiters c, 
    sys.v_$session a 
WHERE
    c.holding_session = b.sid(+)
    AND c.waiting_session = a.sid(+)
/
@_END
