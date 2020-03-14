REM 
REM  Display last executed SQL statement by session with stats
REM  Author:  Mark Lang, 1998
REM 

PROMPT
PROMPT LAST EXECUTED SQL STATEMENT
PROMPT
ACCEPT usr PROMPT "User name like (ENTER for all): "
ACCEPT sta PROMPT "Status like (ENTER for all): "

@_BEGIN
@_TITLE "LAST EXECUTED SQL STATEMENT"

COLUMN username FORMAT A11
COLUMN status   FORMAT A10
COLUMN text     FORMAT A56 WORD
SET LONG 2000

SELECT
    s.username,
    s.status,
    '(diskrd=' || l.disk_reads
        || ', bufgets=' || l.buffer_gets
        || ', opt='     || l.optimizer_mode || ':' || l.optimizer_cost 
        || ', rows='    || l.rows_processed
        || ', sorts='   || l.sorts
        || ', shrmem='  || l.sharable_mem
        || ', permem='  || l.persistent_mem
        || ', runmem='  || l.runtime_mem
        || ')' || &&CR
        || l.sql_text text
FROM
    v$session s,
    v$sql l
WHERE
    s.sql_address = l.address
    AND s.username LIKE NVL(UPPER('&&usr'), '%')
    AND s.status LIKE NVL(UPPER('&&sta'), '%')
;

UNDEFINE usr sta

@_END
