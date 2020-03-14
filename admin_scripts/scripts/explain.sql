REM
REM  Explain the statement from SQL*Plus buffer
REM

@_BEGIN
SET TERMOUT OFF
SPOOL OFF

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
PROMPT Plan &&plan created.
UNDEFINE plan
@_DEFAULT

