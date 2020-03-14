REM 
REM  Set available rollback segments online
REM 

PROMPT
PROMPT SET ROLLBACK SEGMENTS ONLINE
PROMPT
ACCEPT rbs PROMPT "Rollback segment name like (ENTER for all): "
PROMPT

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
    'ALTER ROLLBACK SEGMENT '
    || segment_name
    || ' ONLINE;'
FROM
    sys.dba_rollback_segs
WHERE
    segment_name LIKE NVL(UPPER('&&rbs'), '%')
    AND tablespace_name <> 'SYSTEM'
    AND status = 'OFFLINE'
ORDER BY
    segment_name
;
SPOOL OFF

@_CONFIRM "alter"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE rbs

@_END
