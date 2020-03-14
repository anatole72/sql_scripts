REM 
REM  Display session and system events
REM  Author: Mark Lang, 1998
REM

PROMPT
PROMPT SESSION AND SYSTEM EVENTS 
PROMPT

ACCEPT usr  PROMPT "User name like (ENTER for all, 0 for system, GROUP function): "
ACCEPT stat PROMPT "Event like (ENTER for all): "
ACCEPT min  PROMPT "Minimal waiting time (ENTER for 0): " NUMBER

@_BEGIN
@_WTITLE "SESSION AND SYSTEM EVENTS"

COLUMN username       FORMAT A30            HEADING Username
COLUMN event          FORMAT A30            HEADING Event
COLUMN total_waits    FORMAT 99999999990    HEADING "Waits"
COLUMN total_timeouts FORMAT 999999990      HEADING "Timeouts"
COLUMN time_waited    FORMAT 99999999999990 HEADING "Time Waited|(1/100 sec)"
COLUMN average_wait   FORMAT 9999999990.99  HEADING "Average Wait|(1/100 sec)"

SELECT
    s.username,
    e.event,
    e.total_waits,
    e.total_timeouts,
    e.time_waited,
    e.average_wait
FROM
    v$session_event e,
    v$session s
WHERE
    NVL(UPPER('&&usr'), '%') NOT IN ('0', 'AVG', 'SUM', 'MIN', 'MAX', 'STD', 'VAR')
    AND s.username LIKE NVL(UPPER('&&usr'), '%')
    AND e.sid = s.sid
    AND UPPER(e.event) LIKE NVL(UPPER('&&stat'), '%')
    AND e.time_waited >= &&min
UNION ALL
SELECT
    '*** ' || UPPER('&&usr') || ' ***',
    e.event,
    DECODE(NVL(UPPER('&&usr'), '%'),
        'AVG', AVG(e.total_waits),
        'SUM', SUM(e.total_waits),
        'MIN', MIN(e.total_waits),
        'MAX', MAX(e.total_waits),
        'STD', STDDEV(e.total_waits),
        'VAR', VARIANCE(e.total_waits)
    ) total_waits,
    DECODE(NVL(UPPER('&&usr'), '%'),
        'AVG', AVG(e.total_timeouts),
        'SUM', SUM(e.total_timeouts),
        'MIN', MIN(e.total_timeouts),
        'MAX', MAX(e.total_timeouts),
        'STD', STDDEV(e.total_timeouts),
        'VAR', VARIANCE(e.total_timeouts)
    ) total_timeouts,
    DECODE(NVL(UPPER('&&usr'), '%'),
        'AVG', AVG(e.time_waited),
        'SUM', SUM(e.time_waited),
        'MIN', MIN(e.time_waited),
        'MAX', MAX(e.time_waited),
        'STD', STDDEV(e.time_waited),
        'VAR', VARIANCE(e.time_waited)
    ) time_waited,
    DECODE(NVL(UPPER('&&usr'), '%'),
        'AVG', AVG(e.average_wait),
        'SUM', SUM(e.average_wait),
        'MIN', MIN(e.average_wait),
        'MAX', MAX(e.average_wait),
        'STD', STDDEV(e.average_wait),
        'VAR', VARIANCE(e.average_wait)
    ) average_wait
FROM
    v$session_event e
WHERE
    NVL(UPPER('&&usr'), '%') IN ('AVG', 'SUM', 'MIN', 'MAX', 'STD', 'VAR')
    AND UPPER(e.event) LIKE NVL(UPPER('&&stat'), '%')
    AND e.time_waited >= &&min
GROUP BY
    e.event
UNION ALL
SELECT
    '*** SYSTEM EVENT ***',
    event,
    total_waits,
    total_timeouts,
    time_waited,
    average_wait
FROM
    v$system_event
WHERE
    '&&usr' = '0'
    AND UPPER(event) LIKE NVL(UPPER('&&stat'), '%')
    AND time_waited >= &&min
ORDER BY
    5 DESC
;

UNDEFINE usr stat min

@_END

