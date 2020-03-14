REM
REM  This script lists how many rows are being stored per block
REM  for a selected table
REM

PROMPT
PROMPT HOW MANY ROWS ARE BEING STORED PER TABLE BLOCK
PROMPT

ACCEPT tab PROMPT "Table name ([OWNER.]TABLE): "

@_BEGIN
@_TITLE 'Rows Per Block (&tab)'

SELECT   
    SUBSTR(T.ROWID, 1, 8)  || '-' || SUBSTR(T.ROWID, 15, 4) BLOCK,
    COUNT(*) "ROWS"
FROM     
    &tab T
WHERE    
    ROWNUM < 2000
GROUP BY 
    SUBSTR(T.ROWID, 1, 8) || '-' || SUBSTR(T.ROWID, 15, 4)
;

@_TITLE 'Average Rows Per Block (&tab)'
SELECT   
    AVG(COUNT(*)) "AVERAGE ROWS PER BLOCK"
FROM     
    &tab T
WHERE    
    ROWNUM < 2000
GROUP BY 
    SUBSTR(T.ROWID, 1, 8) || '-' || SUBSTR(T.ROWID, 15, 4)
;

UNDEFINE tab
@_END
