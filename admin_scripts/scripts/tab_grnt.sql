REM
REM  Create output that can recreate all tables grants by many criteria. 
REM

PROMPT
PROMPT RECREATE TABLE GRANTS BY MANY CRITERIA
PROMPT

ACCEPT owner    PROMPT 'Table owner like (ENTER for all): '
ACCEPT table    PROMPT 'Table name like (ENTER for all): '
ACCEPT grantee  PROMPT 'Grantee name like (ENTER for all): '
ACCEPT grantor  PROMPT 'Grantor name like (ENTER for all): '
ACCEPT priv     PROMPT 'Privilege like (ENTER for all): '
PROMPT

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET LINESIZE 250
SET PAGESIZE 0

SELECT 
    'GRANT '
    || privilege
    || ' ON '
    || owner
    || '.'
    || table_name
    || ' TO ' 
    || grantee
    || decode(grantable, 'YES', ' WITH GRANT OPTION') 
    || ' /* BY '
    || grantor
    || ' */;'
FROM 
    dba_tab_privs
WHERE 
    owner LIKE NVL(UPPER('&owner'), '%')
    AND table_name LIKE NVL(UPPER('&table'), '%')
    AND grantee LIKE NVL(UPPER('&grantee'), '%')
    AND grantor LIKE NVL(UPPER('&grantor'), '%')
    AND privilege LIKE NVL(UPPER('&priv'), '%')
ORDER BY
    grantor,
    owner,
    table_name
/
SELECT 
    'GRANT '
    || privilege
    || ' ('
    || column_name
    || ') ON '
    || owner
    || '.'
    || table_name
    || ' TO ' 
    || grantee
    || decode(grantable, 'YES', ' WITH GRANT OPTION') 
    || ' /* BY '
    || grantor
    || ' */;'
FROM 
    dba_col_privs
WHERE 
    owner LIKE NVL(UPPER('&owner'), '%')
    AND table_name LIKE NVL(UPPER('&table'), '%')
    AND grantee LIKE NVL(UPPER('&grantee'), '%')
    AND grantor LIKE NVL(UPPER('&grantor'), '%')
    AND privilege LIKE NVL(UPPER('&priv'), '%')
ORDER BY
    grantor,
    owner,
    table_name
/

UNDEFINE owner 
UNDEFINE table 
UNDEFINE grantee 
UNDEFINE grantor 
UNDEFINE priv 

@_END

