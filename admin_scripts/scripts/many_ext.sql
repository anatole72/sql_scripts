REM
REM  List segments with more then specified number of extents
REM

PROMPT
PROMPT SEGMENTS WITH MANY EXTENTS
PROMPT

ACCEPT ext PROMPT "Min number of extents (ENTER for 0): " 
ACCEPT ts  PROMPT "Tablespace name like (ENTER for all): "
ACCEPT own PROMPT "Owner name like (ENTER for all): "
ACCEPT nam PROMPT "Object name like (ENTER for all): "
ACCEPT typ PROMPT "Object type like (ENTER for all): "

@_BEGIN
@_TITLE 'Segments with more then &ext extents'

COLUMN tspaces  FORMAT A20  HEADING "Tablespace"
COLUMN object   FORMAT A41  HEADING "Object"
COLUMN type     FORMAT A5   HEADING "Type" TRUNCATE
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
    extents > DECODE('&&ext', '', 0, TO_NUMBER('&&ext'))
    AND tablespace_name LIKE NVL(UPPER('&&ts'), '%')
    AND owner LIKE NVL(UPPER('&&own'), '%')
    AND segment_name LIKE NVL(UPPER('&&nam'), '%')
    AND segment_type LIKE NVL(UPPER('&&typ'), '%')
ORDER BY 
    tablespace_name, 
    owner, 
    segment_name
;

UNDEFINE ext ts own nam typ

@_END

