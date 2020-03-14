REM
REM  Rollback segments behaviour watcher (to use as a demo script how
REM  rollback segments are working)
REM

@_BEGIN
@_TITLE "ROLLBACK SEGMENTS WATCHER"

COLUMN name         FORMAT A18          HEADING "Rollback|Segment"
COLUMN status       FORMAT A2           HEADING "St" TRUNCATE
COLUMN extents      FORMAT 999          HEADING "Exts"
COLUMN rssize       FORMAT 99999        HEADING "Size,K"
COLUMN writes       FORMAT 999,999,999  HEADING "Written|Bytes"
COLUMN curext       FORMAT 999          HEADING "Curr|Ext"
COLUMN curblk       FORMAT 9999         HEADING "Curr|Block"
COLUMN wraps        FORMAT 9999         HEADING "Wraps"
COLUMN extends      FORMAT 999          HEADING "Ext-|ends"
COLUMN gets         FORMAT 99999        HEADING "Header|Gets"
COLUMN xacts        FORMAT 99           HEADING "TXs"

SELECT
    name,
    status,
    extents,
    rssize / 1024 rssize,
    writes,
    curext,
    curblk,
    wraps,
    extends,
    gets,
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
