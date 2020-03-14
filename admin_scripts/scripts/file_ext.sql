REM 
REM  Show datafile AUTOEXTEND characteristics
REM

@_BEGIN
@_TITLE "DATAFILE AUTOEXTENDING"

COLUMN file#    FORMAT 90           HEADING "#"
COLUMN name     FORMAT A37 WRAP     HEADING "File Name"
COLUMN maxext   FORMAT 999,990      HEADING "Max Ext(M)"
COLUMN inc      FORMAT 999,990      HEADING "Incr(M)"
COLUMN blocks   FORMAT 9,999,990    HEADING "Size(M)"
COLUMN used     FORMAT 990.0        HEADING "% Max"

DEFINE maxext = "(x.maxextend * t.blocksize / (1024 * 1024))"
DEFINE inc =    "(x.inc * t.blocksize / (1024 * 1024))"
DEFINE blocks = "(f.blocks * t.blocksize / (1024 * 1024))"

SELECT
    v.file#,
    v.name,
    &&maxext maxext,
    &&inc inc,
    &&blocks blocks,
    DECODE(x.maxextend, NULL, 0, 0, 0, f.blocks / NVL(x.maxextend, 0)) * 100 used
FROM
    sys.filext$ x,
    v$dbfile v,
    sys.file$ f,
    sys.ts$ t
WHERE
    f.file# = v.file#
    AND f.file# = x.file#
    AND f.ts# = t.ts#
ORDER BY
    v.file#
;

UNDEFINE maxext inc blocks

@_END

