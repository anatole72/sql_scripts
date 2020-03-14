REM
REM  List of users and their segments in a particular tablespace
REM

@_SET
SET HEADING OFF

PROMPT
PROMPT SEGMENTS IN A TABLESPACE
PROMPT
PROMPT List of tablespaces:

SELECT tablespace_name
FROM dba_tablespaces
ORDER BY tablespace_name;

PROMPT
ACCEPT ts PROMPT "Tablespace name: "

@_BEGIN
@_TITLE "SEGMENTS IN &ts"

COLUMN owner        FORMAT A30
COLUMN segment_name FORMAT A30

BREAK ON owner SKIP 2
COMPUTE COUNT OF segment_name ON owner

SELECT 
   owner,
   segment_name, 
   segment_type
FROM 
   dba_segments 
WHERE
   tablespace_name = UPPER('&ts')
ORDER BY  
   owner, 
   segment_name
;

UNDEFINE ts
@_END

