REM
REM  SCRIPT FOR CREATING SYNONYMS
REM
REM  Running this script will in turn create a script to build 
REM  synonyms in the database. The created script can be run 
REM  by any user with the DBA role or with the 'CREATE ANY SYNONYM' 
REM  and 'CREATE PUBLIC SYNONYM' system privileges.
REM 

PROMPT
PROMPT A SCRIPT TO RECREATE SYNONYMS IN THE DATABASE
PROMPT

ACCEPT sown PROMPT "Synonym owner like (ENTER for all): "
ACCEPT town PROMPT "Table owner like (ENTER for all): "
PROMPT

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0
 
SELECT 
    'CREATE ' || DECODE(owner, 'PUBLIC', 'PUBLIC ', NULL) || 
    'SYNONYM ' || DECODE(owner, 'PUBLIC', NULL, owner || '.') || 
    LOWER(synonym_name) || &&LF ||
    'FOR ' || LOWER(table_owner) ||
    '.' || LOWER(table_name) || 
    DECODE(db_link, NULL, NULL, '@' || db_link) || ';' ||
    &&LF || ' ' || &&LF
FROM
    sys.dba_synonyms
WHERE
    /* table_owner != 'SYS' AND */
    table_owner LIKE NVL(UPPER('&&town'), '%')
    AND owner LIKE NVL(UPPER('&&sown'), '%')
ORDER BY
    owner
/

UNDEFINE sown town
@_END
