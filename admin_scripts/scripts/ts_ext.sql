REM
REM  Phisycal placement of segment extents in a tablespace 
REM

@_SET
SET HEADING OFF

PROMPT
PROMPT EXTENT MAP FOR A TABLESPACE
PROMPT
PROMPT List of tablespaces:

SELECT tablespace_name
FROM dba_tablespaces
ORDER BY tablespace_name;

PROMPT
ACCEPT tbspace PROMPT "Tablespace name: "

@_BEGIN
@_TITLE "EXTENT MAP FOR &tbspace"

COLUMN "File"   FORMAT 999
COLUMN "Start"  FORMAT 9999999
COLUMN "Blocks" FORMAT 99999
COLUMN seg_name FORMAT A43      HEADING "Segment Name" 
COLUMN "Type"   FORMAT A9
COLUMN "Ext#"   FORMAT A4

SELECT 
   file_id "File", 
   block_id "Start", 
   blocks "Blocks", 
   owner || '.' || segment_name seg_name, 
   segment_type "Type",
   TO_CHAR(extent_id) "Ext#"
FROM 
   sys.dba_extents
WHERE 
   tablespace_name = UPPER('&&tbspace')
UNION
SELECT 
   file_id, 
   block_id, 
   blocks,
   'F r e e   S p a c e', 
   ' ', 
   ' '
FROM 
   sys.dba_free_space
WHERE 
   tablespace_name = UPPER('&&tbspace')
ORDER BY 
   1, 2 
;

UNDEFINE tbspace
@_END
