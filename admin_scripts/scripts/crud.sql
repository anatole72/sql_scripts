REM 
REM  Display access privileges to objects in CRUD chart by role
REM  Author: Mark Lang, 1998
REM 
REM  Output does not include inherited grants.
REM 

PROMPT
PROMPT ACCESS PRIVILEGES TO OBJECTS IN C-R-U-D CHART BY ROLE
PROMPT

SET HEADING OFF
SET FEEDBACK OFF

ACCEPT own PROMPT "Object owner like (ENTER for all): "
ACCEPT nam PROMPT "Object name like (ENTER for all): "

PROMPT
PROMPT Allowable object types:

SELECT DISTINCT object_type
FROM dba_objects
WHERE object_type NOT IN (
        'SYNONYM',
        'INDEX',
        'PACKAGE BODY',
        'TRIGGER'
); 
PROMPT

ACCEPT typ PROMPT "Object type like (ENTER for all): "
ACCEPT rol PROMPT "Role (grantee) like (ENTER for all): "

@_BEGIN
@_WTITLE "C-R-U-D chart by role"

COLUMN owner        FORMAT A30 HEADING "OWNER"
COLUMN object_name  FORMAT A30 HEADING "OBJECT"
COLUMN grantee      FORMAT A30 HEADING "GRANTEE"
COLUMN object_type  FORMAT A12 HEADING "TYPE"
COLUMN dml          FORMAT A5  HEADING " DML |SIUDX"
COLUMN ddl          FORMAT A3  HEADING "DDL|ARN"
COLUMN grantable    FORMAT A9
BREAK ON owner SKIP1 

SELECT
    o.owner,
    o.object_name,
    MAX(o.object_type) object_type,
    p.grantee,
    MAX(DECODE(p.privilege, 'SELECT', 'S', ' '))
        || MAX(DECODE(p.privilege, 'INSERT', 'I', ' ')) 
        || MAX(DECODE(p.privilege, 'UPDATE', 'U', ' '))
        || MAX(DECODE(p.privilege, 'DELETE', 'D', ' '))
        || MAX(DECODE(p.privilege, 'EXECUTE', 'X', ' ')) dml,
    MAX(DECODE(p.privilege, 'ALTER', 'A', ' '))
        || MAX(DECODE(p.privilege, 'REFERENCES', 'R', ' '))
        || MAX(DECODE(p.privilege, 'INDEX', 'N', ' ')) ddl,
    MAX(DECODE(p.grantable, 'YES', 'YES', ' ')) grantable
FROM
    dba_tab_privs p,
    dba_objects o
WHERE
    o.owner LIKE NVL(UPPER('&&own'), '%')
    AND o.object_name LIKE NVL(UPPER('&&nam'), '%')
    AND o.object_type NOT IN (
        'SYNONYM',
        'INDEX',
        'PACKAGE BODY',
        'TRIGGER'
    ) 
    AND o.object_type LIKE NVL(UPPER('&&typ'), '%')
    AND o.object_name = p.table_name(+)
    AND p.grantee(+) LIKE NVL(UPPER('&&rol'), '%')
GROUP BY
    o.owner,
    o.object_name,
    p.grantee
ORDER BY
    o.owner,
    o.object_name
;

UNDEFINE own nam rol typ

@_END

