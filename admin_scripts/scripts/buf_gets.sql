PROMPT
PROMPT  This script lists all statements that are taking longer than 2 seconds 
PROMPT  to scan through the buffer cache. The statements use 500 buffer scans 
PROMPT  per second, which we have found that most sites run at.
REM     Author:  Mark Gurry 

@_BEGIN
@_TITLE "Statements in Shared Pool with the Most Buffer Gets"

SET NUMWIDTH 8
COLUMN "Response"   FORMAT 999,999.99
COLUMN sql_text     FORMAT A40 HEADING "Statement" WORD_WRAP
BREAK ON sql_text SKIP 1

SELECT  
    sql_text, 
    buffer_gets "Gets", 
    executions "Execs", 
    buffer_gets / DECODE(executions, 0, 1, executions) "Average",
    buffer_gets / DECODE(executions, 0, 1, executions) / 500 "Response"  
FROM  
    v$sqlarea 
WHERE  
    buffer_gets / DECODE(executions, 0, 1, executions) > 1000
ORDER BY
    buffer_gets / DECODE(executions, 0, 1, executions) DESC
;
@_END
