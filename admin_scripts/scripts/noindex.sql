REM
REM  This script lists all tables that do not have any indexes.
REM
REM  Author: Mark Gurry
REM

@_BEGIN
@_TITLE "Report on all Tables Without Indexes"
BREAK ON owner SKIP 1

SELECT owner, table_name 
FROM dba_tables
--
MINUS
--
SELECT owner, table_name 
FROM dba_indexes
/

@_END
