REM
REM  Datafiles for tablespaces
REM

@_BEGIN
@_TITLE 'TABLESPACE DATAFILES'

COLUMN file_name        FORMAT A50
COLUMN tablespace_name  FORMAT A17
COLUMN meg              FORMAT 99,999.90

BREAK ON tablespace_name SKIP 1 ON REPORT

COMPUTE SUM OF meg ON tablespace_name
COMPUTE SUM OF meg ON REPORT

SELECT
    tablespace_name, 
    file_name, 
    bytes / 1048576 meg
FROM
    dba_data_files
ORDER BY
    tablespace_name,
    file_id
/

@_END
