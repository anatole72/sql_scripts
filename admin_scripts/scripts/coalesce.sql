REM
REM  Coalesces all tablespaces in a database (7.3)
REM

@_BEGIN

SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

REM Creating of script which will get run later
REM to coalesce tablespaces.

SPOOL &SCRIPT
SELECT
    'ALTER TABLESPACE ' ||
    tablespace_name || ' ' ||
    'COALESCE;' || CHR(10) ||
    'COMMIT;'
FROM 
    DBA_TABLESPACES
ORDER BY 
    TABLESPACE_NAME 
/            
SPOOL OFF

@_CONFIRM "coalesce"
@_BEGIN

SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

@_END
