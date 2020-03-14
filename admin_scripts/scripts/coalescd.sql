REM
REM  Shows number of extents in each tablespace
REM  that have been coalesced. 
REM

@_BEGIN
@_TITLE "Coalesced Extents per Tablespace"

COLUMN tablespace_name              HEADING "Tablespace Name"
COLUMN total_extents                HEADING "Total|Extents"
COLUMN extents_coalesced            HEADING "Extents|Coalesced"
COLUMN percent_extents_coalesced    HEADING "% Extents|Coalesced"

SELECT 
    tablespace_name, 
    total_extents, 
    extents_coalesced, 
    percent_extents_coalesced
FROM 
    dba_free_space_coalesced
ORDER BY
    tablespace_name
;
@_END
