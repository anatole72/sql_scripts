REM
REM   Find space used for one's own segments.
REM

@_BEGIN
SET LINESIZE 80
TTITLE 'Space Used on this Account'

COLUMN object   FORMAT A30
COLUMN type     FORMAT A5
COLUMN blocks   FORMAT 99999999
COLUMN extents  FORMAT 999

BREAK ON REPORT PAGE ON type SKIP 1	

COMPUTE SUM OF blocks ON type
COMPUTE SUM OF extents ON type

COMPUTE SUM OF blocks ON REPORT	
COMPUTE SUM OF extents ON REPORT

SELECT 
    segment_name OBJECT, 
    segment_type TYPE, 
    blocks BLOCKS, 
    extents EXTENTS
FROM 
    user_segments
ORDER BY 
    segment_type, 
    segment_name
;
@_END
