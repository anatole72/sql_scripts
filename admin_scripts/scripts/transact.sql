REM
REM  Active transactions
REM

@_BEGIN
@_TITLE "ACTIVE TRANSACTIONS"

COLUMN username     FORMAT A25  HEADING "Username(SID)"
COLUMN used_ublk                HEADING "Used Undo|Blocks"
COLUMN start_time   FORMAT A17  HEADING "Start Time"    
COLUMN start_scnb               HEADING "Start SCN"
COLUMN name         FORMAT A15  HEADING "Rollback|Segment"

SELECT
    s.username || '(' || s.sid || ')' username,
    r.name,
    t.used_ublk,
    t.start_time,
    t.start_scnb
FROM
    v$session s,
    v$transaction t,
    v$rollname r
WHERE
    s.taddr = t.addr
    AND t.xidusn = r.usn
ORDER BY
    s.username
;

@_END
