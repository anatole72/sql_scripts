REM
REM Lists the session id, user process id, server process id,
REM OS user id, and Oracle user id for the current session.
REM

@_BEGIN
@_TITLE "My Session"

SELECT 
    s.sid       "SessionID", 
    s.process   "ProcessID", 
    p.spid      "OraclePID", 
    s.osuser    "OS User", 
    s.username  "Oracle User"
FROM 
    v$session s, 
    v$process p
WHERE 
    audsid = USERENV('SESSIONID') 
    AND s.paddr = p.addr
;

@_END
