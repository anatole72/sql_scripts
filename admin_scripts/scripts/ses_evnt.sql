REM
REM  Generate a report on session events by user
REM 

PROMPT
PROMPT SESSION EVENTS BY USER
PROMPT
ACCEPT usr PROMPT "Username like (ENTER for all): "
ACCEPT evn PROMPT "Event like (ENTER for all): "
ACCEPT ord PROMPT "Order by ((W)aits, time(O)uts, (T)ime, (A)verage): " 

@_BEGIN
@_WTITLE "SESSION EVENTS BY USER"

COLUMN sid            	HEADING Sid
COLUMN event         	HEADING Event           FORMAT A40
COLUMN total_waits    	HEADING Total|Waits
COLUMN total_timeouts 	HEADING Total|Timeouts
COLUMN time_waited    	HEADING Time|Waited
COLUMN average_wait 	HEADING Average|Wait
COLUMN username       	HEADING User            FORMAT A30
BREAK ON username

SELECT 
    username || '(' || a.sid || ')' username, 
    event, 
    total_waits, 
    total_timeouts,
    time_waited, 
    average_wait 
FROM 
    sys.v_$session_event a, 
    sys.v_$session b
WHERE 
    a.sid = b.sid
    AND username LIKE NVL(UPPER('&&usr'), '%')
    AND UPPER(event) LIKE NVL(UPPER('&&evn'), '%')
ORDER BY
    username,
    DECODE(UPPER('&&ord'),
        'W', total_waits,
        'O', total_timeouts,
        'T', time_waited,
        'A', average_wait,
        NULL
    ) DESC
;

UNDEFINE usr evn ord
@_END
