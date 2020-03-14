REM
REM  I/O (expressed in database blocks) by datafile
REM

@_BEGIN
@_HIDE

COLUMN sum_io NEW_VALUE divide_by NOPRINT
SELECT SUM(phyrds + phywrts) sum_io FROM v$filestat;

@_SET
@_WTITLE "CUMULATIVE INPUT/OUTPUT BY DATAFILE"

COLUMN name     HEADING "File Name"         FORMAT A60
COLUMN read     HEADING "Blocks|Read" 
COLUMN ratio    HEADING "Blocks|Per Read"   FORMAT 999.9
COLUMN write    HEADING "Blocks|Written" 
COLUMN total    HEADING "Total IO|Blocks" 
COLUMN percent  HEADING 'Percent|Of IO'     FORMAT 999.99 

BREAK ON REPORT

COMPUTE SUM OF read     ON REPORT
COMPUTE SUM OF write    ON REPORT
COMPUTE SUM OF total    ON REPORT
COMPUTE SUM OF percent  ON REPORT

SELECT
   df.name name,
   fs.phyblkrd read,
   fs.phyblkrd / DECODE(fs.phyrds, 0, 1, fs.phyrds) ratio,
   fs.phyblkwrt write,
   fs.phyblkrd + fs.phyblkwrt total,
   ((fs.phyrds + fs.phywrts) / &divide_by) * 100 percent
FROM
   v$filestat fs, 
   v$datafile df
WHERE
   df.file# = fs.file#
ORDER BY
   fs.phyblkrd + fs.phyblkwrt DESC
;

UNDEFINE divide_by
@_END
