REM
REM  All about System Change Number
REM

@_BEGIN

@_TITLE "SYSTEM CHANGE NUMBER"
TTITLE OFF
SET HEADING OFF
SELECT ' ' FROM sys.dual;

COLUMN scn NOPRINT NEW_VALUE last_scn;

WHENEVER SQLERROR EXIT;
CREATE TABLE temp$scn (scn VARCHAR2(20));
INSERT INTO temp$scn VALUES (USERENV('commitscn'));
SELECT scn FROM temp$scn;
DROP TABLE temp$scn;

TTITLE ON
COLUMN num NOPRINT

SELECT 1 num, 'Last used SCN:                         ' || 
    &last_scn 
FROM sys.dual
UNION ALL
SELECT 2, 'Last SCN checkpointed:                 ' || 
    checkpoint_change# 
FROM v$database
UNION ALL
SELECT 3, 'Time of last SCN checkpointed:         ' || 
    TO_CHAR(TO_DATE(SUBSTR(checkpoint_time, 1, 8), 'MM/DD/YY')) || 
    SUBSTR(checkpoint_time, 9)
FROM v$thread
UNION ALL
SELECT 4, 'Lowest SCN checkpointed in datafiles:  ' || 
    MIN(checkpoint_change#) 
FROM v$datafile
UNION ALL
SELECT 5, 'First SCN in the current log:          ' || 
    first_change# 
FROM v$log
WHERE status = 'CURRENT'
UNION ALL
SELECT 6, 'Time of first SCN in the current log:  ' || 
    TO_CHAR(TO_DATE(SUBSTR(first_time, 1, 8), 'MM/DD/YY')) || 
    SUBSTR(first_time, 9)
FROM v$log
WHERE status = 'CURRENT'
UNION ALL
SELECT 7, 'First SCN in the last (archived) log:  ' || 
    archive_change# 
FROM v$database
ORDER BY 1;

UNDEFINE last_scn
@_END
