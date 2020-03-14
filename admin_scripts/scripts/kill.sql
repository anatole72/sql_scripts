REM
REM  Kills active user session(s)
REM 

@_SET
PROMPT
PROMPT K I L L   S E S S I O N

COLUMN usr  FORMAT A30 HEADING "Username"
COLUMN sid  FORMAT A11 HEADING "Sid/Serial#"
COLUMN term FORMAT A30 HEADING "Terminal/OSUser"

SELECT 
    username usr,
    TO_CHAR(sid) || ',' || TO_CHAR(serial#) sid,
    terminal || '/' || osuser term
FROM 
    v$session
WHERE
    username IS NOT NULL
ORDER BY 
    username
/

PROMPT
ACCEPT usr PROMPT "Username like (ENTER for all): "
ACCEPT ses PROMPT "Session to kill (Sid,Serial# or ENTER for %): "
PROMPT

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
    'ALTER SYSTEM KILL SESSION '
    || CHR(39)
    || sid
    || ','
    || serial#
    || CHR(39)
    || ';'
FROM
    v$session
WHERE
    username LIKE NVL(UPPER('&&usr'), '%')
    AND LTRIM(TO_CHAR(sid)) || ',' || LTRIM(TO_CHAR(serial#)) LIKE
        NVL('&&ses', '%')
    AND status != 'KILLED'
;
SPOOL OFF

@_CONFIRM "kill"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE usr ses

@_END
