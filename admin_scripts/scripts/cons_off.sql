REM 
REM  Disables table integrity constraints
REM  Author: Mark Lang, 1998
REM

PROMPT
PROMPT DISABLE INTEGRITY CONSTRAINTS
PROMPT

ACCEPT own PROMPT "Table owner like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "
ACCEPT typ PROMPT "Constraint type (%, P, U, C, R, append * to cascade): "
DEFINE type = "REPLACE(REPLACE(UPPER('&&typ'), '%', 'PUCR'), '*')"
DEFINE casc = "DECODE(SIGN(INSTR('&&typ', '*')), 1, ' CASCADE', '')"
PROMPT

@_BEGIN
SET HEADING OFF
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
    'ALTER TABLE ' || c.owner || '.' || c.table_name || &&CR||
    'DISABLE CONSTRAINT ' || c.constraint_name || &&casc || ';'
FROM
    dba_constraints c
WHERE
    c.owner <> 'SYS'
    AND c.owner LIKE NVL(UPPER('&&own'), '%')
    AND c.table_name LIKE NVL(UPPER('&&nam'), '%')
    AND INSTR(&&type, c.constraint_type) > 0
    AND status = 'ENABLED'
ORDER BY
    c.owner,
    c.table_name,
    DECODE(c.constraint_type, 'P', 1, 'U', 2, 'C', 3, 'R', 4, 5),
    c.constraint_name
;
SPOOL OFF

@_CONFIRM "disable"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE own nam typ type casc

@_END
