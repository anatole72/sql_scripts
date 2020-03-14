REM    
REM  Compute the space used by an entry for an existing index.
REM

@_BEGIN

PROMPT
PROMPT COMPUTE THE SPACE USED BY AN ENTRY FOR AN EXISTING INDEX
PROMPT

DEFINE qt = CHR(39)
DEFINE cr = 'CHR(10)'

ACCEPT towner PROMPT 'Table owner name: '
ACCEPT tname  PROMPT 'Table name: '
PROMPT
ACCEPT iowner PROMPT 'Index owner name: '
ACCEPT iname  PROMPT 'Index name: '

COLUMN dum1 	NOPRINT
COLUMN rowcount NEW_VALUE countrow NOPRINT
COLUMN strcount NEW_VALUE strct NOPRINT
COLUMN isize 	FORMAT 99,999.99
COLUMN rcnt 	FORMAT 999,999,999  	

@_HIDE
SELECT COUNT(*) rowcount FROM &&towner..&&tname;
SELECT TO_CHAR(&&countrow) strcount FROM DUAL;

SPOOL &SCRIPT
SELECT 
    -1 dum1,
    'SELECT ' || &&qt ||
    'Proposed index on table ' ||
        UPPER('&&towner..&&tname') || ' has &&strct entries of ' ||
        &&qt || ', ('
FROM 
    &&towner..&&tname 
UNION
SELECT 
    column_id,
    'SUM(NVL(VSIZE(' || column_name || '), 0)) + 1 +' 
FROM 
    dba_tab_columns 
WHERE 
    table_name = '&tname'
    AND owner = '&towner' 
    AND column_name IN (
        SELECT column_name 
        FROM dba_ind_columns 
        WHERE 
            table_name = UPPER('&tname') 
            AND table_owner = UPPER('&towner')
            AND index_name = UPPER('&iname')
            AND index_owner = UPPER('&iowner')
        )
    AND column_id <> (
        SELECT MAX(column_id)
        FROM dba_tab_columns
        WHERE 
            table_name = UPPER('&tname')
            AND owner = UPPER('&towner')
            AND column_name IN (
                SELECT column_name 
                FROM dba_ind_columns 
                WHERE 
                    table_name = UPPER('&tname')
                    AND table_owner = UPPER('&towner')
                    AND index_name = UPPER('&iname')
                    AND index_owner = UPPER('&iowner')
                )
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
    AND column_name IN (
        SELECT column_name 
        FROM dba_ind_columns
        WHERE 
            table_name = UPPER('&tname')
            AND table_owner = UPPER('&towner')
            AND index_name = UPPER('&iname')
            AND index_owner = UPPER('&iowner')
        )
    AND column_id = (
        SELECT MAX(column_id)
        FROM dba_tab_columns
        WHERE 
            table_name = UPPER('&tname') 
	        AND owner = UPPER('&towner')
            AND column_name IN (
                SELECT column_name 
                FROM dba_ind_columns 
                WHERE 
                    table_name = UPPER('&tname')
                    AND table_owner = UPPER('&towner')  
		            AND index_name = UPPER('&iname')
                    AND index_owner = UPPER('&iowner')
            )
        )
UNION 
SELECT 
    997,
    '/ COUNT(*) + 11 isize, '' bytes each.'''  
FROM DUAL
UNION 
SELECT 
    999,  
    'FROM &towner..&tname.;'  
FROM dual;
SPOOL OFF

@_BEGIN
SET HEADING OFF

@&SCRIPT

UNDEFINE tname towner iname iowner
@_END

