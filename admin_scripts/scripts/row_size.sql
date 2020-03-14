REM
REM Calculates average row size in a table
REM

PROMPT
PROMPT AVERAGE ROW SIZE IN A TABLE
PROMPT

ACCEPT towner 	PROMPT 'Table owner name: '
ACCEPT tname  	PROMPT 'Table name: '

@_BEGIN

SET PAGESIZE 0
SET VERIFY OFF
SET TERMOUT OFF
SET FEEDBACK OFF

COLUMN dum1  	NOPRINT
COLUMN rsize 	FORMAT 99,999.99
COLUMN rcount 	FORMAT 999,999,999 NEWLINE 

SPOOL &SCRIPT
SELECT 
    0 dum1,
    'SELECT ''Table ' || UPPER('&towner..&tname') ||
    ' has '', COUNT(*) rcount, '' rows of '', ('   
FROM 
    dual
UNION
SELECT 
    column_id,
    'SUM(NVL(VSIZE(' || column_name || '), 0)) + 1 +'  
FROM 
    dba_tab_columns 
WHERE 
    table_name = UPPER('&tname') 
    AND owner = UPPER('&towner')
    AND column_id <> (
        SELECT MAX(column_id)
        FROM dba_tab_columns
		WHERE table_name = UPPER('&tname')
		AND owner = UPPER('&towner')
    )
UNION
SELECT 
    column_id,
    'SUM(NVL(VSIZE(' || column_name || '), 0)) + 1)'
FROM 
    dba_tab_columns 
WHERE 
    table_name = UPPER('&tname') 
    AND owner = UPPER('&towner')
    AND column_id = (
        SELECT MAX(column_id)
        FROM dba_tab_columns
		WHERE table_name = UPPER('&tname')
		AND owner = UPPER('&towner')
    )
UNION 
SELECT 997,  '/ COUNT(*) + 5 rsize, '' bytes each'''  FROM DUAL
UNION 
SELECT 999,  'FROM &towner..&tname.;'  FROM DUAL;
SPOOL OFF

@_BEGIN

SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF

@&SCRIPT

UNDEF CFILE
UNDEF TNAME
UNDEF TOWNER

@_END

