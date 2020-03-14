REM 
REM  Grants select on SYS tables to users
REM  Author:  Mark Lang, 1998
REM

PROMPT
PROMPT GRANT SELECT ON SYS OBJECTS TO USERS (WITH GRANT OPTION)
PROMPT

ACCEPT obj PROMPT "Object name like (ENTER for all): "
PROMPT
PROMPT Allowable object types:
PROMPT
PROMPT (T)able
PROMPT (V)iew
PROMPT (P)rocedure
PROMPT (F)unction
PROMPT packa(G)e
PROMPT ENTER for all
PROMPT
ACCEPT typ PROMPT "Object type: "
ACCEPT usr PROMPT "Grantee name like (ENTER for PUBLIC): "
PROMPT

@_BEGIN
SET HEADING OFF
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
    'GRANT '
    || DECODE(
        o.object_type, 
        'PROCEDURE', 'EXECUTE',
        'FUNCTION', 'EXECUTE',
        'PACKAGE', 'EXECUTE',
        'SELECT'
    )
    || ' ON SYS.'
    || o.object_name
    || ' TO '
    || NVL(UPPER('&&usr'), 'PUBLIC')
    || &&CR
    || 'WITH GRANT OPTION;'
FROM
    sys.dba_objects o
WHERE
    o.owner = 'SYS'
    AND o.object_name LIKE NVL(UPPER('&&obj'), '%')
    AND o.object_type LIKE DECODE(UPPER('&&typ'),
        'T', 'TABLE',
        'V', 'VIEW',
        'P', 'PROCEDURE',
        'F', 'FUNCTION',
        'G', 'PACKAGE',
        NULL, '%',
        '?'
    )
    AND o.object_type IN (
        'TABLE',
        'VIEW',
        'PROCEDURE',
        'FUNCTION',
        'PACKAGE'
    )
    AND EXISTS (
        SELECT name
        FROM sys.user$
        WHERE name = NVL(UPPER('&&usr'), 'PUBLIC')
    )
    AND NOT EXISTS (
        SELECT * FROM sys.dba_tab_privs
        WHERE
            grantee = NVL(UPPER('&&usr'), 'PUBLIC')
            AND owner = 'SYS'
            AND table_name = o.object_name
            AND privilege IN ('SELECT', 'EXECUTE')
            AND grantable = 'YES'
    )
;
SPOOL OFF

@_CONFIRM "grant"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE obj typ usr

@_END
