REM 
REM  Display Oracle i/o distribution by file, tablespace, or device.
REM  Author: Mark Lang, 1998
REM   

PROMPT
PROMPT I/O DISTRIBUTION BY FILE, TABLESPACE, OR DEVICE
PROMPT
ACCEPT opt PROMPT "By (F)ile, (T)ablespace, (D)evice (ENTER for F): "
PROMPT

@_BEGIN

VARIABLE n_rd NUMBER
VARIABLE n_wr NUMBER

@_HIDE
BEGIN
    SELECT
        SUM(phyblkrd),
        SUM(phyblkwrt)
    INTO
        :n_rd,
        :n_wr
    FROM
        v$filestat
    ;
END;
/
@_SET

@_TITLE "INPUT/OUTPUT DISTRIBUTION"

COLUMN name     FORMAT a30      HEADING "Name"
COLUMN tsize	FORMAT 9,990 	HEADING "MBytes"
COLUMN reads    FORMAT 999,990  HEADING "Physical|Reads"
COLUMN readp    FORMAT 999      HEADING "Read|   %" JUSTIFY RIGHT
COLUMN writs    FORMAT 999,990  HEADING "Physical|Writes"
COLUMN writp    FORMAT 990      HEADING "Wri-|te %" JUSTIFY RIGHT
COLUMN total    FORMAT 999,990  HEADING "Physical|Total"
COLUMN totlp    FORMAT 990      HEADING "Tot-|al %" JUSTIFY RIGHT

DEFINE nameln = 30
DEFINE devsep = "GREATEST(0, -
    INSTR(df.name, '/', -1), -
    INSTR(df.name, ':', -1), -
    INSTR(df.name, '\', -1))"

DEFINE device = "SUBSTR(df.name, 1, &&devsep)"
DEFINE filenm = "SUBSTR(df.name, &&devsep + 1)"
DEFINE name   = "DECODE(UPPER('&&opt'), 'T', ts.name, 'D', &&device, df.name)"

SELECT
    MAX(&&name) name,
    SUM(df.bytes / (1024 * 1024)) tsize,
    SUM(st.phyblkrd) / 1000 reads,
    SUM(st.phyblkrd) / (:n_rd) * 100 readp,
    SUM(st.phyblkwrt) / 1000 writs,
    SUM(st.phyblkwrt) / (:n_wr) * 100 writp,
    SUM(st.phyblkrd + st.phyblkwrt) / 1000 total,
    SUM(st.phyblkrd + st.phyblkwrt) / (:n_rd + :n_wr) * 100 totlp
FROM
    v$datafile df,
    v$filestat st,
    sys.file$ sf,
    sys.ts$ ts
WHERE
    df.file# = st.file#
    AND df.file# = sf.file#
    AND sf.ts# = ts.ts#
GROUP BY
    DECODE(UPPER('&&opt'),
        'T', ts.name,
        'D', &&device,
        df.file#
    )
;

UNDEFINE opt

@_END

