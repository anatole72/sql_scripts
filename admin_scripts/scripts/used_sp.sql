REM
REM  Tablespace user quota information
REM

@_BEGIN
@_TITLE "USED SPACE BY USERNAME"

COLUMN username         FORMAT A30              HEADING 'Username'
COLUMN tablespace_name  FORMAT A30              HEADING 'Tablespace'
COLUMN used             FORMAT 9,999,999,999    HEADING 'Bytes Used'

COMPUTE SUM OF used ON username        
BREAK ON username SKIP 1 ON REPORT

SELECT 
    owner username, 
    tablespace_name, 
    SUM(bytes) used
FROM   
    sys.dba_segments 
GROUP BY 
    owner, 
    tablespace_name 
ORDER BY 
    1, 3 DESC
/

@_TITLE "USED SPACE BY TABLESPACE"

COLUMN username         FORMAT A30              HEADING 'Username'
COLUMN tablespace_name  FORMAT A30              HEADING 'Tablespace'
COLUMN used             FORMAT 9,999,999,999    HEADING 'Bytes Used'

COMPUTE SUM OF used ON tablespace_name 
BREAK ON tablespace_name SKIP 1 ON REPORT

SELECT 
    tablespace_name, 
    owner username, 
    SUM(bytes) used
FROM   
    sys.dba_segments 
GROUP BY 
    owner, 
    tablespace_name 
ORDER BY 
    1, 3 DESC
/
@_END	
