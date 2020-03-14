REM
REM  Show Parallel Query vital stats
REM 

@_BEGIN
@_TITLE "PARALLEL QUERY STATISTICS"

COLUMN idle_time_total  FORMAT 9990     HEADING "IDLE"
COLUMN busy_time_total  FORMAT 9990     HEADING "BUSY"
COLUMN cpu_secs_total   FORMAT 99990    HEADING "CPU(s)"
COLUMN msgs_sent_total  FORMAT 9990     HEADING "MSENT"
COLUMN msgs_rcvd_total  FORMAT 9990     HEADING "MRCVD"

SELECT
    slave_name,
    status,
    sessions, 
    idle_time_total,
    busy_time_total,
    cpu_secs_total,
    msgs_sent_total,
    msgs_rcvd_total 
FROM
    v$pq_slave
ORDER BY
    slave_name
;

@_END
