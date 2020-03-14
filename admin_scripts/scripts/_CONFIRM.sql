REM
REM  Embedded script to prompt user before an action.
REM  First parameter is the word describing the action, for example:
REM  @_CONFIRM "execute"
REM 

PROMPT
ACCEPT dummy CHAR PROMPT "Press ENTER to &&1 or CTRL+C to cancel..." HIDE
UNDEFINE dummy

