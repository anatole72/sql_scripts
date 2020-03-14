REM
REM  Cumulative hit ratio since instance startup
REM

@_BEGIN
@_TITLE "CUMULATIVE HIT RATIO"

COLUMN log_reads  FORMAT 999,999,999 HEADING "Logical Reads"
COLUMN phy_reads  FORMAT 999,999,999 HEADING "Physical Reads"
COLUMN ratio      FORMAT 999.00      HEADING "HIT RATIO (%)"

SELECT 
    a.value + b.value log_reads, 
    c.value           phy_reads,
    ROUND(100 * (a.value + b.value - c.value) / 
                (a.value + b.value), 2) ratio
FROM   
    v$sysstat a, 
    v$sysstat b, 
    v$sysstat c
WHERE  
    a.name = 'db block gets'
    AND b.name = 'consistent gets'
    AND c.name = 'physical reads'
/

@_END
	
