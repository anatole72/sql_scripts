REM 
REM  Performs "command" on each column
REM 
REM  Notes:
REM  1. USE WITH CAUTION!
REM  2. Executes <command> for each object matched--substitutions to
REM     <command> are made as follows:
REM
REM		{o}	owner
REM		{n}	object_name
REM     {c} column_name
REM		{y}	data_type
REM
REM  Author:  Mark Lang, 1998
REM 

PROMPT
PROMPT PERFORM "COMMAND" ON EACH COLUMN
PROMPT
PROMPT The "command" must be defined using following substitution parameters:
PROMPT {o} for owner, {n} for table name and, {c} for column name and {y} for
PROMPT column data type. For example:
PROMPT
PROMPT GRANT UPDATE({c}) ON {o}.{n} TO SCOTT;

@_CONFIRM "continue"

PROMPT
ACCEPT cmd PROMPT "Command: " 
ACCEPT own PROMPT "Table owner like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "
ACCEPT clm PROMPT "Column name like (ENTER for all): "
ACCEPT typ PROMPT "Column type like (ENTER for all): "
PROMPT

@_BEGIN
SET HEADING OFF
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
    REPLACE(
        REPLACE(
            REPLACE(
                REPLACE(
                    '&&cmd',
                    '{o}', o.owner
                ),
                '{n}', o.table_name
            ),
            '{y}', o.data_type
        ),
        '{c}', o.column_name
    ) text
FROM
    dba_tab_columns o
WHERE
    o.owner LIKE NVL(UPPER('&&own'), '%')
    AND o.table_name LIKE NVL(UPPER('&&nam'), '%')
    AND o.data_type LIKE NVL(UPPER('&&typ'), '%')
    AND o.column_name LIKE NVL(UPPER('&&clm'), '%')
ORDER BY
    o.owner,
    o.table_name,
    o.column_name
;
SPOOL OFF

@_CONFIRM "execute"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE cmd own nam typ clm

@_END
