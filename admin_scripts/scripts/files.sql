REM
REM  All database files report
REM

@_BEGIN

@_TITLE "CONTROL FILES"
SET HEADING OFF

SELECT
    name                       
FROM
    sys.v_$controlfile
/

@_SET
@_TITLE "DIRECTORIES"

SELECT
    SUBSTR(name, 1, 25) parameter,
    SUBSTR(value, 1, 53) value
FROM
    sys.v_$parameter
WHERE
    name LIKE '%archive_dest%'
    OR name LIKE '%dump_dest%'
/

@_TITLE "LOG FILES"

COLUMN Grp#     FORMAT 9999
COLUMN member   FORMAT A60  HEADING "ONLINE REDO LOGS"
COLUMN File#    FORMAT 9999
BREAK ON Grp

SELECT *
FROM   sys.v_$logfile
/

@_TITLE "LAST 10 ARCHIVED REDO LOGS"

COLUMN sequence#    FORMAT 99999    HEADING "SEQ#"
COLUMN archive_name FORMAT A54      HEADING "ARCHIVED REDO LOGS"
COLUMN time         FORMAT A17

SELECT
    sequence#,
    archive_name,
    time
FROM
    sys.v_$log_history
WHERE
    ROWNUM < 10
/

@_TITLE "DATA FILES"

COLUMN tablespace FORMAT A15
COLUMN status     FORMAT A3     HEADING STS
COLUMN id         FORMAT 99
COLUMN mbyte      FORMAT 9999
COLUMN name       FORMAT A49    HEADING "FILES NAMES"

BREAK ON REPORT
COMPUTE SUM OF Mbyte ON report

SELECT 
    file_id id, 
    file_name name, 
    bytes / (1024 * 1024) Mbyte,
    DECODE(status, 'AVAILABLE', 'OK', status) status, 
    tablespace_name tablespace
FROM   
    sys.dba_data_files
ORDER BY
    file_id
/

@_END	
