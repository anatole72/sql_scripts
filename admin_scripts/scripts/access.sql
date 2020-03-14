REM
REM  Show objects currently in use in the database
REM

PROMPT
PROMPT OBJECTS CURRENTLY IN USE IN THE DATABASE
PROMPT

ACCEPT os_user  PROMPT "OS user name like (ENTER for all): "
ACCEPT ora_user PROMPT "Oracle user name like (ENTER for all): "

@_BEGIN
@_WTITLE "Database Objects Access"

COLUMN username FORMAT A30
COLUMN object   FORMAT A61
BREAK ON osuser ON username ON sid

SELECT 
    s.osuser, 
    s.username, 
    s.sid, 
    a.type,
    a.owner || '.' || a.object object
FROM   
    sys.v_$session s,
    sys.v_$access a
WHERE  
    a.sid = s.sid  
    AND s.osuser   LIKE NVL(LOWER('&os_user'), '%')
    AND s.username LIKE NVL(UPPER('&ora_user'), '%')
ORDER BY 
    osuser,
    username,
    sid,
    type,
    object
/

UNDEFINE os_user
UNDEFINE ora_user

@_END
