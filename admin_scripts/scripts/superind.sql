REM
REM  This simple script lists all indexes that have the same leading 
REM  column on a table and may be superfluous.
REM
REM  Author: Mark Gurry
REM

@_BEGIN
@_TITLE "INDEXES WHICH MAY BE SUPERFLUOUS"

COLUMN table_owner FORMAT A21
COLUMN table_name  FORMAT A28
COLUMN column_name FORMAT A28

SELECT 
    table_owner, 
    table_name,
    column_name 
FROM  
    dba_ind_columns 
WHERE  
    column_position = 1
GROUP BY 
    table_owner, 
    table_name, 
    column_name
HAVING  
    count(*) > 1
;
@_END
