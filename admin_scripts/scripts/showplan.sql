REM
REM  Does structured display of EXPLAIN PLAN
REM

@_SET
SET FEEDBACK OFF
SET HEADING OFF
SET PAGESIZE 0

PROMPT
PROMPT TREE-STRUCTURED OUTPUT FROM THE PLAN TABLE
PROMPT
PROMPT Existing Statement ID:
PROMPT

SELECT DISTINCT NVL(statement_id, 'DEFAULT')
FROM plan_table
ORDER BY 1;

PROMPT
ACCEPT stm PROMPT "Statement ID (ENTER for DEFAULT): "
PROMPT

SET LINESIZE 80
COLUMN query_plan FORMAT A79

SELECT
    DECODE(id, 0, '', LPAD(' ', 2 * (level - 1)) || level || '.' || position || ' ')
    || operation
    || DECODE(options, NULL, '', ' (' || options || ')')
    || ' ' || object_name  
    || ' ' || DECODE(id, 0, 'Cost = ' || position) query_plan
FROM
    plan_table
START WITH
    id = 0
    AND NVL(statement_id, 'DEFAULT') = NVL('&&stm', 'DEFAULT')
CONNECT BY
    prior id = parent_id
    AND NVL(statement_id, 'DEFAULT') = NVL('&&stm', 'DEFAULT')
;
PROMPT

UNDEFINE stm
@_DEFAULT
