REM 
REM  Display privileges granted to a user or role (an all-purpose script)
REM 
REM  Author: Mark Lang, 1998
REM

PROMPT
PROMPT PRIVILEGES GRANTED TO A USER OR ROLE
PROMPT

ACCEPT gr PROMPT "Grantee (user or role) like (ENTER for all): "
DEFINE grt = "NVL(UPPER('&&gr'), '%')"

ACCEPT ty PROMPT "Privilege type ([S]ystem [R]ole [T]able [C]olumn or ENTER for all): "
DEFINE typ = "NVL(UPPER('&&ty'), 'SRTC')"

ACCEPT pr PROMPT "Privilege like (ENTER for all): "
DEFINE prv = "NVL(UPPER('&&pr'), '%')"

ACCEPT ow PROMPT "Table owner like (ENTER for all): "
DEFINE own = "NVL(UPPER('&&ow'), '%')"

ACCEPT na PROMPT "Table name like (ENTER for all): "
DEFINE nam = "NVL(UPPER('&&na'), '%')"

ACCEPT cl PROMPT "Column name like (ENTER for all): "
DEFINE cln = "NVL(UPPER('&&cl'), '%')"

@_BEGIN
@_TITLE "PRIVILEGES GRANTED TO USER(S) OR ROLE(S)"

COLUMN sortby       NOPRINT
COLUMN grantee      FORMAT A20
COLUMN priv_type    FORMAT A1
COLUMN privilege    FORMAT A20
COLUMN object       FORMAT A32
COLUMN options      FORMAT A2

SELECT
    1 sortby,
    grantee,
    'S' priv_type,
    privilege,
    DECODE(admin_option, 'YES', 'A', '') options,
    '' object
FROM
    dba_sys_privs p
WHERE
    grantee LIKE &&grt
    AND INSTR(&&typ, 'S') > 0
    AND privilege LIKE &&prv
UNION ALL
SELECT
    2 sortby,
    grantee,
    'R',
    granted_role,
    DECODE(admin_option, 'YES', 'A', '')
        || DECODE(default_role, 'YES', 'D', '') options,
    ''
FROM
    dba_role_privs p
WHERE
    grantee LIKE &&grt
    AND INSTR(&&typ, 'R') > 0
    AND granted_role LIKE &&prv
UNION ALL
SELECT
    3 sortby,
    grantee,
    'T',
    privilege,
    DECODE(grantable, 'YES', 'G', '') options,
    owner || '.' || table_name
FROM
    dba_tab_privs p
WHERE
    grantee like &&grt
    AND INSTR(&&typ, 'T') > 0
    AND privilege LIKE &&prv
    AND owner LIKE &&own
    AND table_name LIKE &&nam
UNION ALL
SELECT
    3 sortby,
    grantee,
    'C',
    privilege,
    DECODE(grantable, 'YES', 'G', '') options,
    owner || '.' || table_name || '(' || column_name || ')'
FROM
    dba_col_privs p
WHERE
    grantee LIKE &&grt
    AND INSTR(&&typ, 'C') > 0
    AND privilege LIKE &&prv
    AND owner LIKE &&own
    AND table_name LIKE &&nam
    AND column_name LIKE &&cln
ORDER BY
    1, 2, 4, 5
;

UNDEFINE gr grt
UNDEFINE ty typ
UNDEFINE pr prv
UNDEFINE ow own
UNDEFINE na nam
UNDEFINE cl cln

@_END
