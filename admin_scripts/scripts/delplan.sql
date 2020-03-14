REM
REM  Delete a plan from the plan table for given statement(s)
REM

@_SET
SET FEEDBACK OFF
SET PAGESIZE 0

PROMPT
PROMPT DELETE STATEMENT(S) FROM THE PLAN TABLE
PROMPT
PROMPT Existing Statement ID:
PROMPT

SELECT DISTINCT NVL(statement_id, 'DEFAULT')
FROM plan_table
ORDER BY 1;

PROMPT
ACCEPT stm PROMPT "Statement ID to delete like (ENTER for all): "

SET FEEDBACK ON
DELETE FROM plan_table
WHERE NVL(statement_id, 'DEFAULT') LIKE NVL('&&stm', '%');

@_CONFIRM "commit"
COMMIT;

UNDEFINE stm
@_DEFAULT

