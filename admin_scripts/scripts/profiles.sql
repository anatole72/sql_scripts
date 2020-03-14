REM 
REM  Display profiles
REM 

PROMPT
PROMPT P R O F I L E S
PROMPT
ACCEPT pro PROMPT "Profile name like (ENTER for all): "
ACCEPT res PROMPT "Resource name like (ENTER for all): "
ACCEPT lim PROMPT "Limit like (ENTER for all): "

@_BEGIN
@_TITLE "P R O F I L E S"

COLUMN profile          FORMAT A30
COLUMN resource_name    FORMAT A30
COLUMN limit            FORMAT A17
BREAK ON profile SKIP 1

SELECT 
    profile,
    resource_name,
    limit
FROM
    sys.dba_profiles
WHERE
    profile LIKE NVL(UPPER('&&pro'), '%')
    AND resource_name LIKE NVL(UPPER('&&res'), '%')
    AND limit LIKE NVL(UPPER('&&lim'), '%')
ORDER BY
    profile,
    resource_name
;

UNDEFINE pro res lim

@_END

