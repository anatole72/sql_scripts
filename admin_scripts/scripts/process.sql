REM
REM  Generate a list of current oracle SIDs/PIDs
REM

@_BEGIN
@_WTITLE "CURRENT ORACLE PROCESSES"

COLUMN program  FORMAT A25
COLUMN pid      FORMAT 9999
COLUMN sid      FORMAT 9999
COLUMN osuser   HEADING OS_USER

SELECT 
    NVL(a.username, '?') username,
    b.pid,
    a.sid,
    a.serial#,
    DECODE(a.terminal, '?', 'Detached', a.terminal) terminal,
    b.program,
    b.spid,
    a.osuser
FROM 
    v$session a, 
    v$process b
WHERE 
    a.sid = b.pid(+) 
ORDER BY 
    a.username,
    b.pid
/

@_END
