REM
REM   List segments with a number of allocated extents close to
REM   their MAX_EXTENTS.
REM
REM   last_exts is the exception margin; for example, if the table
REM   is allowed to have 90 extents (max_extents=90), and last_exts=10,
REM   that table will show up in this report if and only if the number of
REM   extents exceeds 80.  Use a small last_exts to only see the tables
REM   in the most trouble; use a large last_exts if you also want to see
REM   tables in less trouble.
REM

PROMPT
PROMPT SEGMENTS CLOSE TO MAX_EXTENTS
PROMPT

ACCEPT last_exts PROMPT "Number of last extents: " NUMBER
ACCEPT ts  PROMPT "Tablespace name like (ENTER for all): "
ACCEPT own PROMPT "Owner name like (ENTER for all): "
ACCEPT nam PROMPT "Object name like (ENTER for all): "
ACCEPT typ PROMPT "Object type like (ENTER for all): "

@_BEGIN
@_TITLE 'Segments Close to Max_Extents'

COLUMN tspaces  FORMAT A20  HEADING "Tablespaces"
COLUMN object   FORMAT A41  HEADING "Object"
COLUMN type     FORMAT A5   HEADING "Type"  TRUNCATE
COLUMN extents  FORMAT 99   HEADING " Ext"
COLUMN maxexts  FORMAT 9999 HEADING "Max"
BREAK ON tspaces SKIP 1

SELECT 
    tablespace_name tspaces, 
    owner || '.' || segment_name object, 
    segment_type type, 
    extents, 
    max_extents maxexts
FROM 
    dba_segments
WHERE 
    max_extents - extents < &last_exts
    AND segment_name NOT IN ('SPACES')
    AND tablespace_name LIKE NVL(UPPER('&&ts'), '%')
    AND owner LIKE NVL(UPPER('&&own'), '%')
    AND segment_name LIKE NVL(UPPER('&&nam'), '%')
    AND segment_type LIKE NVL(UPPER('&&typ'), '%')
    AND segment_type <> 'CACHE'
ORDER BY 
    tablespace_name, 
    owner, 
    segment_name
;

UNDEFINE last_exts ts own nam typ
@_END

