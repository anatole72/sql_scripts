REM
REM  Calculates table size directly.
REM
REM  NOTE: The script is working very slow usually. 
REM

PROMPT
PROMPT CALCULATE TABLE SIZE
PROMPT

ACCEPT owner PROMPT "Table owner: "
ACCEPT tablename PROMPT "Table name: "

@_BEGIN
@_TITLE "SIZE OF THE TABLE &&owner..&&tablename"

COLUMN blocks HEADING "Allocated Blocks"
COLUMN used   HEADING "Blocks Used"

SELECT 
    blocks,
    COUNT(DISTINCT SUBSTR(t.rowid, 1, 8) || SUBSTR(t.rowid, 15, 4)) used,
    ROUND(COUNT(DISTINCT SUBSTR(t.rowid, 1, 8) || SUBSTR(t.rowid, 15, 4)) / 
        blocks * 100) "% Used"
FROM 
    sys.dba_segments e, 
    &&owner..&&tablename t
WHERE 
    e.owner = UPPER('&&owner')
    AND e.segment_name = UPPER('&&tablename')
    AND e.segment_type = 'TABLE'
GROUP BY 
    e.blocks
;

UNDEFINE owner tablename
@_END
