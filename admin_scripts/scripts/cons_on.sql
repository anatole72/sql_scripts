REM
REM  Enables integrity constraints
REM  Author: Mark Lang, 1998
REM

PROMPT
PROMPT ENABLE INTEGRITY CONSTRAINTS
PROMPT

ACCEPT own PROMPT "Table owner like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "
ACCEPT typ PROMPT "Constraint type (%, P, U, C, R): "
ACCEPT exc PROMPT "Exception table (* if none, ? if standard): "
PROMPT

DEFINE type = "REPLACE(UPPER('&&typ'), '%', 'PUCR')"
DEFINE excp = "UPPER('&&exc')"

@_BEGIN
SET HEADING OFF
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
    'ALTER TABLE ' || c.owner || '.' || c.table_name || &&CR ||
    'ENABLE CONSTRAINT ' || c.constraint_name ||
    DECODE(&&excp, '*', '', ' EXCEPTIONS INTO ' ||
    DECODE(&&excp, '?', 'EXCEPTIONS', &&excp)) ||
    ';'
FROM
    dba_constraints c
WHERE
    c.owner <> 'SYS'
    AND c.owner LIKE NVL(UPPER('&&own'), '%')
    AND c.table_name LIKE NVL(UPPER('&&nam'), '%')
    AND INSTR(&&type, c.constraint_type) > 0
    AND status != 'ENABLED'
ORDER BY
    c.owner,
    c.table_name,
    DECODE(c.constraint_type, 'P', 1, 'U', 2, 'C', 3, 'R', 4, 5),
    c.constraint_name
;
SPOOL OFF

@_CONFIRM "enable"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE own nam typ type exc excp

@_END

