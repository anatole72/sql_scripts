REM
REM  Report all DB locks
REM

@_BEGIN
@_TITLE 'Report on All Locks'

COLUMN osuser           FORMAT A13  HEADING 'OS User'
COLUMN session_id       FORMAT 999  HEADING 'SID'
COLUMN mode_held        FORMAT A15  HEADING 'Mode Held'
COLUMN mode_requested   FORMAT A15  HEADING 'Mode Requested'
COLUMN lock_id1         FORMAT A8   HEADING 'Lock ID1'
COLUMN lock_id2         FORMAT A8   HEADING 'Lock ID2'
COLUMN type                         HEADING 'Lock Type'

SELECT 
    NVL(a.osuser, 'SYS') osuser,
    b.session_id,
    type,
    mode_held,
    mode_requested,
    lock_id1,
    lock_id2
FROM 
    sys.v_$session a, sys.dba_locks b
WHERE
    a.sid = b.session_id
ORDER BY 
    2
/
@_END
