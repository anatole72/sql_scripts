REM
REM  A script to identify "poorly performing" SQL statements
REM

PROMPT
PROMPT POORLY PERFORMED SQL STATEMENTS
PROMPT
ACCEPT hit PROMPT "Hit ratio threshold (ENTER for 0.8): "

@_BEGIN
@_TITLE "POORLY PERFORMED SQL STATEMENTS"

COLUMN executions       HEADING "Execu|tions"   FORMAT 99999
COLUMN disk_reads       HEADING "Disc|Reads"    FORMAT 999999
COLUMN reads_per_run    HEADING "Reads|Per Run" FORMAT 99999.99
COLUMN buffer_gets      HEADING "Buffer|Gets"   FORMAT 999999
COLUMN hit_ratio        HEADING "Hit|Ratio"     FORMAT 999.99
COLUMN sql_text         HEADING "SQL Statement" FORMAT A38 WORD_WRAP

SELECT 
    executions, 
    disk_reads, 
    ROUND(disk_reads / executions, 2) reads_per_run,
    buffer_gets, 
    ROUND((buffer_gets - disk_reads) / buffer_gets, 2) hit_ratio,
    sql_text
FROM
    v$sqlarea
WHERE
    executions  > 0
    AND buffer_gets > 0
    AND (buffer_gets - disk_reads) / buffer_gets <
        NVL(TO_NUMBER('&&hit'), 0.8)
ORDER BY
    5 DESC 
/
UNDEFINE hit
@_END
