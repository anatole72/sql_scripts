REM
REM  Ping a database
REM 

@_BEGIN

PROMPT
PROMPT PING A DATABASE
PROMPT
ACCEPT db PROMPT "Database link: "
PROMPT

SET HEADING OFF
SET TIMING ON
SELECT
    'Ping successful to '
    || UPPER('&&db')
    || ' at '
    || TO_CHAR(SYSDATE, 'Dy Mon DD, YYYY HH24:MI:SS')
    || '.'
FROM
    DUAL@&&db
;
SET TIMING OFF

@_END
