REM
REM  Rollback segments statistics
REM

@_BEGIN
@_TITLE "ROLLBACK SEGMENTS STATISTICS"

COLUMN name         FORMAT A12      HEADING "Rollback|Segment"
COLUMN status       FORMAT A7       HEADING "Status" TRUNCATE
COLUMN extents      FORMAT 999      HEADING "Exte|-nts"
COLUMN rssize       FORMAT 99999    HEADING "Size|(Kb)"
COLUMN hwmsize      FORMAT 99999    HEADING "HighWM|(Kb)"
COLUMN optsize      FORMAT 99999    HEADING "Optim|(Kb)"
COLUMN shrinks      FORMAT 999      HEADING "Shri|-nks"
COLUMN wraps        FORMAT 999      HEADING "Wra|-ps"
COLUMN extends      FORMAT 999      HEADING "Exte|-nds"
COLUMN aveshrink    FORMAT 99999    HEADING "AvgShr|(Kb)"
COLUMN aveactive    FORMAT 99999    HEADING "AvgAct|(Kb)"
COLUMN xacts        FORMAT 99       HEADING "TXs"

SELECT
    name,
    status,
    extents,
    rssize / 1024 rssize,
    hwmsize / 1024 hwmsize,
    optsize / 1024 optsize,
    shrinks,
    wraps,
    extends,
    aveshrink / 1024 aveshrink,
    aveactive / 1024 aveactive,
    xacts
FROM
    v$rollstat s,
    v$rollname r
WHERE
    s.usn = r.usn
ORDER BY
    name
;

@_END
