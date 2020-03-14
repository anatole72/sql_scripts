REM
REM  Report of direct object grants to users and 
REM  direct object grants to roles.
REM
REM  By Joseph C. Trezzo, modified by S.S.
REM

PROMPT
PROMPT DIRECT OBJECTS GRANTS
PROMPT

ACCEPT own PROMPT "Object owner like (ENTER for all): "
ACCEPT nam PROMPT "Object name like (ENTER for all): "
ACCEPT pri PROMPT "Granted privilege like (ENTER for all): "
ACCEPT grn PROMPT "Grantee name like (ENTER for all): "

@_BEGIN
@_TITLE "Direct Objects Grants"

COLUMN username      FORMAT A23  HEADING "Grantee"
COLUMN obj           FORMAT A38  HEADING "Object"
COLUMN what_granted  FORMAT A12  HEADING "Granted|Privilege"
COLUMN grantable     FORMAT A3   HEADING "Adm|Opt"

SELECT 
    p.owner || '.' || p.table_name obj,
    p.privilege what_granted,
    p.grantable,
    u.username
FROM
    sys.dba_users u,
    sys.dba_tab_privs p
WHERE
    u.username = p.grantee
    AND p.owner LIKE NVL(UPPER('&&own'), '%')
    AND p.table_name LIKE NVL(UPPER('&&nam'), '%')
    AND p.privilege LIKE NVL(UPPER('&&pri'), '%')
    AND p.grantee LIKE NVL(UPPER('&&grn'), '%')
UNION ALL
SELECT 
    owner || '.' || table_name obj,
    privilege what_granted,
    grantable,
    grantee
FROM
    sys.dba_tab_privs
WHERE
    NOT EXISTS (
        SELECT 'x' FROM dba_users
        WHERE username = grantee
        )
    AND owner LIKE NVL(UPPER('&&own'), '%')
    AND table_name LIKE NVL(UPPER('&&nam'), '%')
    AND privilege LIKE NVL(UPPER('&&pri'), '%')
    AND grantee LIKE NVL(UPPER('&&grn'), '%')
ORDER BY 
    1, 2, 3
/

UNDEFINE own nam pri grn

@_END
