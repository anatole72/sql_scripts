REM
REM Author: Mark Gurry
REM

PROMPT
PROMPT The following scripts list the number of rollbacks performed on the 
PROMPT transaction tables:
PROMPT 
PROMPT (i)  'transaction tables consistent reads - undo records applied' is the 
PROMPT total # of undo records applied to rollback transaction tables only. It
PROMPT should be < 10% of the total number of consistent changes
PROMPT 
PROMPT (ii) 'transaction tables consistent read rollbacks' is the number of times
PROMPT the transaction tables were rolled back. It should be less than 0.1 % of 
PROMPT the value of consistent gets. 
PROMPT 
PROMPT If either of these scenarios occurs, consider creating more rollback 
PROMPT segments, or a greater number of extents in each rolback segment. A 
PROMPT rollback segment equates to a transaction table and an extent is like a 
PROMPT transaction slot in the table. 
PROMPT
PROMPT RECOMMENDATIONS:

@_BEGIN

SET HEADING OFF
COLUMN nl NEWLINE

SELECT 
    'Tran Table Consistent Read Rollbacks > 1% of Consistent Gets' nl,
    'Action: Create more Rollback Segments'
FROM 
    v$sysstat
WHERE 
    DECODE (name, 
        'transaction tables consistent read rollbacks', value) * 100 /
    DECODE (name,
        'consistent gets', value) > 0.1
    AND name IN ( 
        'transaction tables consistent read rollbacks',
        'consistent gets'
    )
    AND value > 0
; 

SELECT 
    'Undo Records Applied > 10% of Consistent Changes' nl,
    'Action: Create more Rollback Segments'
FROM 
    v$sysstat
WHERE 
    DECODE (name,
        'transaction tables consistent reads - undo records applied', value
        ) * 100 /
    DECODE (name, 'consistent changes', value) > 10  
    AND name IN (
        'transaction tables consistent reads - undo records applied', 
        'consistent changes')
    AND value > 0
;

@_END
