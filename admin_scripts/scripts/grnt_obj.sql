REM 
REM  Grant privileges on objects
REM  Author: Mark Lang, 1998
REM

PROMPT
PROMPT GRANT PRIVILEGES ON OBJECTS
PROMPT

ACCEPT o PROMPT "Object owner like (ENTER for all): "
DEFINE own = "NVL(UPPER('&&o'), '%')"

ACCEPT n PROMPT "Object name like (ENTER for all): "
DEFINE nam = "NVL(UPPER('&&n'), '%')"

ACCEPT t PROMPT "Object type like (ENTER for all): "
DEFINE typ = "NVL(UPPER('&&t'), '%')"

ACCEPT p PROMPT "Privilege (append * if with grant option): "
DEFINE prv = "UPPER(REPLACE('&&p', '*'))"
DEFINE grt = "DECODE(SUBSTR('&&p', LENGTH('&&p'), 1), '*', 'YES', 'NO')"

ACCEPT u PROMPT "Grantee (user or role): "
DEFINE usr = "UPPER('&&u')"
PROMPT

@_BEGIN
SET HEADING OFF
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
    'GRANT '
    || p.name
    || ' ON '
    || o.owner
    || '.'
    || o.object_name
    || ' TO '
    || u.name
    || DECODE(&&grt, 'YES', ' WITH GRANT OPTION', '')
    || ';'
FROM
    sys.dba_objects o,
    sys.user$ u,
    table_privilege_map p
WHERE
    u.name = &&usr
    AND o.owner LIKE &&own
    AND o.object_name LIKE &&nam
    AND o.object_type LIKE &&typ
    AND o.object_type NOT IN (
        'SYNONYM',
        'INDEX',
        'TRIGGER',
        'PACKAGE BODY',
        'DATABASE LINK'
    )
    AND p.name IN (
        'SELECT',
        'INSERT',
        'UPDATE',
        'DELETE',
        'EXECUTE',
        'ALTER',
        'INDEX',
        'REFERENCES'
    )
    AND (
        p.name LIKE &&prv
        OR (&&prv = 'READ' AND p.name IN ('SELECT', 'EXECUTE'))
        OR (&&prv = 'WRITE' AND p.name IN ('SELECT', 'INSERT', 'UPDATE', 'DELETE',
            'EXECUTE'))
        OR &&prv = 'ALL'
    )
    AND (
        p.name NOT IN ('INSERT','UPDATE','DELETE')
        OR o.object_type IN ('TABLE','VIEW')
    )
    AND (p.name NOT IN ('INDEX', 'REFERENCES') OR o.object_type = 'TABLE')
    AND (
        p.name != 'EXECUTE'
        OR o.object_type IN ('FUNCTION', 'PROCEDURE', 'PACKAGE')
    )
    AND NOT EXISTS (
        SELECT 0
        FROM sys.dba_tab_privs
        WHERE
            grantee = u.name
            AND owner = o.owner
            AND table_name = o.object_name
            AND privilege = p.name
            AND (
                &&grt = 'NO'
                OR grantable = 'YES'
            )
    )
ORDER BY
    o.owner,
    o.object_name
;
SPOOL OFF

@_CONFIRM "execute"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE o own n nam t typ p prn grt u usr

@_END
