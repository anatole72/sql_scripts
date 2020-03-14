REM
REM  Rebuild indexes or move indexes to another tablespace
REM 

PROMPT
PROMPT REBUILD INDEXES (POSSIBLY IN ANOTHER TABLESPACE)
PROMPT

ACCEPT o PROMPT "Table owner like (ENTER for all): "
DEFINE own = "NVL(UPPER('&&o'), '%')"

ACCEPT n PROMPT "Table name like (ENTER for all): "
DEFINE nam = "NVL(UPPER('&&n'), '%')"

ACCEPT i PROMPT "Index name like (ENTER for all): "
DEFINE idx = "NVL(UPPER('&&i'), '%')"

ACCEPT ot PROMPT "Old tablespace like (ENTER for all): "
DEFINE ots = "NVL(UPPER('&&ot'), '%')"

ACCEPT nt PROMPT "New tablespace (ENTER to ignore): "
DEFINE nts = "DECODE('&&nt', NULL , '', ' TABLESPACE ' || UPPER('&&nt'))"
PROMPT

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
    'ALTER INDEX '
    || i.owner
    || '.'
    || i.index_name
    || &&CR
    || 'REBUILD'
    || &&nts
    || ';'
FROM
    dba_indexes i
WHERE
    i.table_owner LIKE &&own
    AND i.table_name LIKE &&nam
    AND i.index_name LIKE &&idx
    AND i.tablespace_name LIKE &&ots
ORDER BY
    i.owner,
    i.table_name,
    i.index_name
;
SPOOL OFF

@_CONFIRM "rebuild"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE o own
UNDEFINE n nam
UNDEFINE i idx
UNDEFINE ot ots
UNDEFINE nt nts

@_END

