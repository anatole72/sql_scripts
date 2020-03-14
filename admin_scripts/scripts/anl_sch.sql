REM
REM  Creates and runs script which will analyze all objects for users 
REM  using DBMS_UTILITY.ANALYZE_SCHEMA
REM

PROMPT
PROMPT ANALYZE SCHEMAS USING DBMS_UTILITY
PROMPT

ACCEPT o PROMPT "Schema like (ENTER for all): "
ACCEPT m PROMPT "Method ((C)ompute, (E)stimate, (D)elete): "
ACCEPT n PROMPT "Number of rows (ENTER for 0): "
ACCEPT p PROMPT "Percent to use (ENTER for 0): "
PROMPT

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

REM Creating of script which will get run later
REM to analyze all schemas.

SPOOL &SCRIPT
SELECT DISTINCT 
    'EXECUTE DBMS_UTILITY.ANALYZE_SCHEMA('
    || CHR(39) ||
    owner || CHR(39)
    || ', ' || CHR(39)
    || DECODE(UPPER('&m'),
        'C', 'COMPUTE',
        'E', 'ESTIMATE',
        'D', 'DELETE',
        '?') || CHR(39)
    || ', ' || NVL('&n', '0')
    || ', ' || NVL('&p', '0') || ');'
FROM 
    dba_tables 
WHERE 
    owner NOT IN ('SYS','SYSTEM')
    AND owner LIKE NVL(UPPER('&o'), '%')
/
SPOOL OFF

@_CONFIRM "analyze"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE o
UNDEFINE m 
UNDEFINE n 
UNDEFINE p 

@_END
