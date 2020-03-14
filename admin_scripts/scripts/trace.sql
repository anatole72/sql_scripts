REM 
REM  Set SQL_TRACE on/off in selected user sessions
REM 

@_SET
PROMPT
PROMPT SET SQL_TRACE ON/OFF IN SELECTED USER SESSIONS

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
ACCEPT sid PROMPT "Session like (Sid,Serial# or ENTER for %): "
ACCEPT mod PROMPT "Set trace to ((T)rue or (F)alse): "
PROMPT

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
    'EXEC SYS.DBMS_SYSTEM.SET_SQL_TRACE_IN_SESSION('
    || '/* ' || username || ' */ ' 
    || TO_CHAR(sid)
    || ', '
    || TO_CHAR(serial#)
    || ', '
    || DECODE(UPPER('&&mod'), 'T', 'TRUE', 'FALSE')
    || ');'
FROM
    v$session
WHERE
    username LIKE NVL(UPPER('&&usr'), '%')
    AND LTRIM(TO_CHAR(sid)) || ',' || LTRIM(TO_CHAR(serial#)) LIKE
        NVL('&&sid', '%')
;
SPOOL OFF

@_CONFIRM "set"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE usr sid mod

@_END

