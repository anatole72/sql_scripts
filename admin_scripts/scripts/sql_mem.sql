REM
REM  Generate a report of SQL area memory usage showing SQL text and 
REM  memory categories.
REM

PROMPT
PROMPT SQL AREA MEMORY USAGE
PROMPT
ACCEPT user_name PROMPT "User name like (ENTER for all): "

@_BEGIN
@_WTITLE "Users SQL Area Memory Using"
SET LONG 1000

COLUMN sql_text         FORMAT A60  HEADING Text WORD_WRAPPED
COLUMN sharable_mem                 HEADING Shared|Bytes
COLUMN persistent_mem               HEADING Persistent|Bytes
COLUMN parse_calls                  HEADING Parses
COLUMN users            FORMAT a15  HEADING "User"
COLUMN executions                   HEADING "Executions"
BREAK ON users SKIP 1

COMPUTE SUM OF sharable_mem     ON users
COMPUTE SUM OF persistent_mem   ON users
COMPUTE SUM OF runtime_mem      ON users

SELECT 
    username users, 
    '*' " ",
    sql_text, 
    executions, 
    parse_calls, 
    sharable_mem, 
    persistent_mem 
FROM 
    sys.v_$sqlarea a, 
    dba_users b
WHERE 
    a.parsing_user_id = b.user_id
    AND b.username LIKE UPPER('%&user_name')
ORDER BY 
    1
;

UNDEFINE user_name
@_END
