REM
REM  Provide list of SID, System PID and username for current oracle users
REM

@_BEGIN
@_TITLE "Oracle System Users"
SELECT 
    a.sid,
    b.spid,
    a.username,
    a.osuser
FROM 
    v$session a,
    v$process b
WHERE 
    a.sid = b.pid(+)
/
@_END
