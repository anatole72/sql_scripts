REM 
REM  Sessions blocking other sessions
REM
REM  To run the script you need to run CATBLOCK.SQL before.
REM 

@_BEGIN
@_WTITLE 'SESSIONS BLOCKING OTHER SESSIONS'

COLUMN username         FORMAT A36 	HEADING 'Holding|User'
COLUMN session_id                   HEADING 'SID'
COLUMN mode_held 		FORMAT A20 	HEADING 'Mode|Held'
COLUMN mode_requested   FORMAT A20 	HEADING 'Mode|Requested'
COLUMN lock_id1         FORMAT A20 	HEADING 'Lock|ID1'
COLUMN lock_id2         FORMAT A20 	HEADING 'Lock|ID2'
COLUMN type                         HEADING 'Lock|Type'
BREAK ON username SKIP 1

SELECT 
	username || '(' || a.session_id || ')' username, 
	type, 
	mode_held, 
	mode_requested,
	lock_id1, 
	lock_id2 
FROM
	sys.v_$session b, 
	sys.dba_blockers c, 
	sys.dba_locks a
WHERE
	c.holding_session = a.session_id
	AND c.holding_session = b.sid
ORDER BY
    1
/
@_END

