REM
REM  Display execution plan for the statement in SQL*Plus buffer
REM

@_BEGIN
SPOOL OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET LINESIZE 80
SET TERMOUT OFF

SAVE &SCRIPT REPLACE

COLUMN plan_name NEW_VALUE plan
SELECT LOWER(USER || '_' || USERENV('SESSIONID')) plan_name FROM DUAL;
COLUMN plan_name CLEAR
DELETE FROM plan_table WHERE statement_id = '&&plan';

GET &SCRIPT
0 EXPLAIN PLAN SET STATEMENT_ID = '&&plan' FOR
/
COMMIT;

SET TERMOUT ON
PROMPT
COLUMN query_plan FORMAT A79
SELECT
    DECODE(id, 0, '', LPAD(' ', 2 * (level - 1)) || level || '.' || position || ' ')
    || operation
    || DECODE(options, NULL, '', ' (' || options || ')')
    || ' ' || object_name  
    || DECODE(id, 0, '(' || statement_id || ')') 
    || ' ' || DECODE(id, 0, 'Cost = ' || position) query_plan
FROM
    plan_table
START WITH
    id = 0
    AND statement_id = '&&plan'
CONNECT BY
    prior id = parent_id
    AND statement_id = '&&plan'
;
PROMPT
SET TERMOUT OFF

UNDEFINE plan
GET &SCRIPT
@_DEFAULT
