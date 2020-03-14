REM 
REM  Redo logs information
REM 

@_BEGIN
@_TITLE "REDO LOGS INFORMATION"

COLUMN group#           FORMAT 90           HEADING "Group#"
COLUMN sequence#        FORMAT 999990       HEADING "Seq#"
COLUMN kbytes           FORMAT 9999990      HEADING "Kb"
COLUMN members          FORMAT 90           HEADING "Members"
COLUMN first_change#    FORMAT 9999999990   HEADING "First Chg#"
COLUMN first_time       FORMAT A14          HEADING "First Time"
COLUMN status           FORMAT A10          HEADING "Status"
COLUMN archived         FORMAT A3           HEADING "Arc"

SELECT
    group#,
    sequence#,
    bytes / 1024 kbytes,
    members,
    first_change#,
    SUBSTR(first_time, 1, 14) first_time,
    status,
    archived
FROM
    v$log
;

@_END
