REM
REM  This script shows the SQL that people who are currently 
REM  being locked are trying to run.
REM
REM  Author:  Mark Gurry
REM

PROMPT
PROMPT LOCKED SQL STATEMENTS
PROMPT
ACCEPT usr PROMPT "Username like (ENTER for all): "
ACCEPT own PROMPT "Object owner like (ENTER for all): "
ACCEPT nam PROMPT "Object name like (ENTER for all): "

@_BEGIN
@_WTITLE "Waiting SQL Statements"

COLUMN users        FORMAT A35
COLUMN object       FORMAT A35
COLUMN statement    FORMAT A50 WORD_WRAP

SELECT
    ses.username || '(' || ses.sid || ')' users, 
    acc.owner || '.' || acc.object object, 
    ses.lockwait, 
    txt.sql_text statement
FROM  
    v$sqltext txt, 
    v$access acc, 
    v$session ses
WHERE
    txt.address = ses.sql_address
    AND txt.hash_value = ses.sql_hash_value
    AND ses.sid = acc.sid
    AND ses.lockwait IS NOT NULL
    AND ses.username LIKE NVL(UPPER('&&usr'), '%')
    AND acc.owner LIKE NVL(UPPER('&&own'), '%')
    AND acc.object LIKE NVL(UPPER('&&nam'), '%')
;

UNDEFINE usr own nam

@_END
