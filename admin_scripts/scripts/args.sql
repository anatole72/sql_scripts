REM 
REM  Display package program unit arguments
REM  Author: Mark Lang, 1998
REM

PROMPT
PROMPT PACKAGE OBJECTS ARGUMENTS
PROMPT

ACCEPT own PROMPT "Package owner like (ENTER for all): "
ACCEPT nam PROMPT "Package name like (ENTER for all): "
ACCEPT obj PROMPT "Object name like (ENTER for all): "
ACCEPT typ PROMPT "Data type like (ENTER for all): "

@_BEGIN
@_TITLE "Package objects arguments"

COLUMN pname        FORMAT A20 WRAP HEADING "Package Name" 
COLUMN oname        FORMAT A20 WRAP HEADING "Object Name"
COLUMN aname        FORMAT A15 WRAP HEADING "Argument"
COLUMN data_type    FORMAT A14      HEADING "Data type"
COLUMN in_out       FORMAT A6       HEADING "In/Out"
BREAK ON pname SKIP 1 ON oname SKIP 1

SELECT 
    owner || '.' || package_name pname,
    object_name || DECODE(overload, NULL, '', '(' || overload || ')') oname,
    argument_name aname,
    data_type,
    in_out
FROM
    all_arguments
WHERE
    owner LIKE NVL(UPPER('&&own'), '%')
    AND package_name LIKE NVL(UPPER('&&nam'), '%')
    AND object_name LIKE NVL(UPPER('&&obj'), '%')
    AND (data_type LIKE NVL(UPPER('&&typ'), '%')
        OR ('&&typ' = '' AND data_type IS NULL))
ORDER BY
    owner,
    package_name,
    object_name,
    overload,
    position
;

UNDEFINE own nam obj typ

@_END

