REM 
REM  Drop or disable foreign keys which references specified tables
REM 

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

PROMPT
PROMPT DISABLE OR DROP FOREIGN KEYS WHICH REFERENCES SPECIFIED TABLES
PROMPT

ACCEPT own1 PROMPT "Referenced table owner like (ENTER for all): "
ACCEPT nam1 PROMPT "Referenced table name like (ENTER for all): "
ACCEPT own2 PROMPT "Referencing table owner like (ENTER for all): "
ACCEPT nam2 PROMPT "Referencing table name like (ENTER for all): "
ACCEPT actn PROMPT "(D)rop or di(S)able foreign keys: "
PROMPT

SPOOL &SCRIPT
SELECT
    'ALTER TABLE '
    || c.owner
    || '.'
    || c.table_name
    || &&CR
    || DECODE(UPPER('&&actn'), 'D', 'DROP', 'S', 'DISABLE', 'ENABLE')
    || ' CONSTRAINT '
    || c.constraint_name
    || ';'
FROM
    dba_constraints c,
    dba_constraints c2
WHERE
    c.constraint_type = 'R'
    AND c.r_owner = c2.owner
    AND c.r_constraint_name = c2.constraint_name
    AND c.owner LIKE NVL(UPPER('&&own2'), '%')
    AND c.table_name LIKE NVL(UPPER('&&nam2'), '%')
    AND c2.owner <> 'SYS'
    AND c2.owner LIKE NVL(UPPER('&&own1'), '%')
    AND c2.table_name LIKE NVL(UPPER('&&nam1'), '%')
;
SPOOL OFF

@_CONFIRM "execute"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE own1 nam1 own2 nam2 actn

@_END
