REM
REM  Application information for sessions
REM

PROMPT
PROMPT SESSIONS APPLICATION INFORMATION
PROMPT
ACCEPT usr PROMPT "Username like (ENTER for all): "

@_BEGIN
@_TITLE "Database client applications"

COLUMN uname        FORMAT A16  HEADING "Username(SID)"
COLUMN status       FORMAT A1   HEADING "S"
COLUMN module       FORMAT A15  HEADING "Module"        WRAP    
COLUMN action       FORMAT A15  HEADING "Action"        WRAP
COLUMN client_info  FORMAT A28  HEADING "Client Info"   WRAP

SELECT
    username || '(' || sid || ')' uname,
    SUBSTR(status, 1, 1) status,
    module,
    action,
    client_info
FROM
    v$session
WHERE
    type = 'USER'
    AND username IS NOT NULL
    AND username LIKE NVL(UPPER('&&usr'), '%')
ORDER BY
    username
;

UNDEFINE usr
@_END


