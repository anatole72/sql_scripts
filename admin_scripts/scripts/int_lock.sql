rem 
rem  Document current internal locks
rem 

PROMPT
PROMPT CURRENT INTERNAL LOCKS
PROMPT

ACCEPT lock PROMPT 'Lock type (ENTER for all): '
ACCEPT mode PROMPT 'Lock mode (ENTER for all): '

@_BEGIN
@_WTITLE 'Report on Internal Locks (Mode:&mode, Type:&lock)'

COLUMN username         FORMAT A16 	HEADING 'Lock Holder'
COLUMN session_id                   HEADING 'User SID'
COLUMN lock_type        FORMAT A30 	HEADING 'Lock Type' WORD_WRAP
COLUMN mode_held        FORMAT A10 	HEADING 'Mode|Held'
COLUMN mode_requested 	FORMAT A10 	HEADING 'Mode|Requested'
COLUMN lock_id1         FORMAT A40 	HEADING 'Lock/Cursor ID1' WORD_WRAP
COLUMN lock_id2         FORMAT A10 	HEADING 'Lock ID2'
BREAK ON username

SELECT 
    NVL(b.username, 'SYS') username, 
    session_id,
    lock_type,
    mode_held,
    mode_requested,
    lock_id1,
    lock_id2
FROM
    sys.dba_lock_internal a,
    sys.v_$session b
WHERE
    UPPER(mode_held) LIKE UPPER('%&mode%')
    OR UPPER('&mode') = ''
        AND UPPER(lock_type) LIKE UPPER('%&lock%')
    OR UPPER(mode_held) LIKE UPPER('%&mode%')   -- A mistake???
    OR UPPER('&mode') = ''
        AND UPPER('&lock') = ''
        AND a.session_id = b.sid
ORDER BY 
    1, 2
/

UNDEFINE LOCK
UNDEFINE MODE
@_END
