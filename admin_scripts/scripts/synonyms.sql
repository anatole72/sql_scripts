REM
REM  GENERATE REPORT OF A USERS SYNONYMS
REM 

PROMPT
PROMPT S Y N O N Y M S   R E P O R T
PROMPT

ACCEPT sown PROMPT 'Synonym owner like (ENTER for all): '
ACCEPT snam PROMPT 'Synonym name like (ENTER for all): '
ACCEPT town PROMPT 'Table owner like (ENTER for all): '
ACCEPT tnam PROMPT 'Table name like (ENTER for all): '

@_BEGIN
@_WTITLE "SYNONYMS REPORT"

COLUMN owner 	FORMAT A16 HEADING Owner
COLUMN synonym_name        HEADING Synonym
COLUMN table 	FORMAT A35 HEADING Object
COLUMN db_link 	FORMAT A6  HEADING Link 
COLUMN username FORMAT A15 HEADING Username
COLUMN host 	FORMAT A24 HEADING "Connect String"
BREAK ON owner SKIP 1

SELECT 
    a.owner, 
    synonym_name, 
    table_owner ||'.'|| table_name "table", 
    b.db_link,
    username, 
    host 
FROM 
    dba_synonyms a, 
    dba_db_links b
WHERE 	
    a.db_link = b.db_link(+) 
    AND a.owner LIKE NVL(UPPER('&sown'), '%')
    AND a.synonym_name LIKE NVL(UPPER('&snam'), '%')
    AND a.table_owner LIKE NVL(UPPER('&town'), '%')
    AND a.table_name LIKE NVL(UPPER('&tnam'), '%')
ORDER BY
    a.owner,
    synonym_name
;

UNDEFINE sown snam town tnam
@_END

