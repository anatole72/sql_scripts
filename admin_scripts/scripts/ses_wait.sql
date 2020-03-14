PROMPT
PROMPT This script lists all waits that are currently occurring on the
PROMPT system and which users are currently waiting.
PROMPT

ACCEPT usr PROMPT "Username like (ENTER for all): "

@_BEGIN
@_WTITLE "S E S S I O N S    W A I T S"

COLUMN users    FORMAT A30  HEADING "Username(SID)"
COLUMN event    FORMAT A48  HEADING "Event"
COLUMN time                 HEADING "Last Wait|(1/100 sec)"
COLUMN sec                  HEADING "Seconds|in Wait"
COLUMN state    FORMAT A19  HEADING "Wait State"
COLUMN comm     FORMAT A9   HEADING "Comment"

SELECT 
    ses.username || '(' || sw.sid || ')' users, 
    sw.event,
    sw.wait_time time,
    sw.seconds_in_wait sec,
    INITCAP(sw.state) state,
    DECODE (sw.wait_time,
        -2, 'Not Timed',
        -1, 'Too Short',
         0, 'Current',
         'Last Wait'
    ) comm
FROM 
    v$session ses, 
    v$session_wait sw
WHERE
    ses.username LIKE NVL(UPPER('&&usr'), '%')
    AND ses.sid = sw.sid
ORDER BY
    ses.username || '(' || sw.sid || ')',
    sw.wait_time DESC
;

UNDEFINE usr

@_END
