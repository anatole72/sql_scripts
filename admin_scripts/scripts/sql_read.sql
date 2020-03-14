REM
REM  This script list all of the SQL statements currently stored in
REM  the shared pool that have disk reads > some seconds. As default,
REM  we suppose that 4 seconds assumes 50 I/Os per second. 
REM
REM  Author:  Mark Gurry
REM

PROMPT
PROMPT READ INTENSIVE SQL STATEMENTS
PROMPT
ACCEPT ios PROMPT "Define number of I/Os per second (ENTER for 50): "
ACCEPT tim PROMPT "Define number of seconds (ENTER for 4): "

@_BEGIN
@_TITLE "STATEMENTS WITH THE MOST DISK READS"
SET NUMWIDTH 8

COLUMN "Average"    FORMAT 9,999,999.99 
COLUMN "Response"   FORMAT 9,999,999.99
COLUMN sql_text     FORMAT A33 WORD_WRAP HEADING "Statement"
BREAK ON sql_text SKIP 1

SELECT  
    sql_text, 
    disk_reads "Reads", 
    executions "Execs", 
    disk_reads / DECODE(executions, 0, 1, executions) "Average",
    disk_reads / DECODE(executions, 0, 1, executions)
        / TO_NUMBER(NVL('&&ios', '50')) "Response"  
FROM
    v$sqlarea 
WHERE  
    disk_reads / DECODE(executions, 0, 1, executions)
        > TO_NUMBER(NVL('&&ios', '50')) * TO_NUMBER(NVL('&&tim', '4'))
;

UNDEFINE ios tim
@_END
