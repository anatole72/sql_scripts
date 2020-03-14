REM
REM  The script lists the default storage for each of the 
REM  tablespaces. 
REM

@_BEGIN
@_TITLE "TABLESPACE DEFAULT STORAGE SETTINGS"

COLUMN tsp FORMAT A30           HEADING "Tablespace"
COLUMN ini FORMAT 9,999,999,999 HEADING "Initial"
COLUMN nex FORMAT 9,999,999,999 HEADING "Next"
COLUMN pct FORMAT 990           HEADING "%Inc"
COLUMN min FORMAT 9999          HEADING "Min"
COLUMN max FORMAT 9999          HEADING "Max"

SELECT 
    tablespace_name tsp, 
    initial_extent ini, 
    next_extent nex, 
    pct_increase pct,
    min_extents min,
    max_extents max
FROM 
    dba_tablespaces
ORDER BY 
    tablespace_name
;
@_END
