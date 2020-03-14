REM
REM  Displays the datafile I/O by tablespace
REM

@_BEGIN
@_WTITLE "I/O Activity by tablespace"

COLUMN tablespace_name FORMAT A27            HEADING "Tablespace Name"
COLUMN fid             FORMAT 9999           HEADING "File"
COLUMN total           FORMAT 99,999,999,990 HEADING "Physical|Total"
COLUMN phyrds          FORMAT 99,999,999,990 HEADING "Physical|Reads"
COLUMN phywrts         FORMAT 99,999,999,990 HEADING "Physical|Writes"
COLUMN phyblkrd        FORMAT 999,999,990    HEADING "Physical|Block Reads"
COLUMN phyblkwrt       FORMAT 999,999,990    HEADING "Physical|Block Writes"
COLUMN avg_rd_time     FORMAT 90.9999999     HEADING "Average|Read Time|Per Block"
COLUMN avg_wrt_time    FORMAT 90.9999999     HEADING "Average|Write Time|Per Block"

BREAK ON tablespace_name SKIP 1
COMPUTE SUM OF total phyrds phywrts phyblkrd phyblkwrt ON tablespace_name

SELECT
    c.tablespace_name,
    a.file# fid,
    a.phyblkrd + a.phyblkwrt total,
    a.phyrds,
    a.phywrts,
    a.phyblkrd,
    a.phyblkwrt,
    ((a.readtim / DECODE(a.phyrds, 0, 1, a.phyblkrd)) / 100) avg_rd_time,
    ((a.writetim / DECODE(a.phywrts, 0, 1, a.phyblkwrt)) / 100) avg_wrt_time
FROM
    v$filestat a,
    v$datafile b,
    sys.dba_data_files c
WHERE
    b.file# = a.file#
    AND b.file# = c.file_id
ORDER BY
    tablespace_name, a.file#
/
@_END

