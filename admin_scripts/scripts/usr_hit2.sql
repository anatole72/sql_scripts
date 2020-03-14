REM
REM  User hit ratios.
REM  Author: Mark Gurry
REM

@_BEGIN
@_TITLE 'USER HIT RATIOS (BY MARK GURRY)'

COLUMN "Hit Ratio"      FORMAT 999.99
COLUMN "User Session"   FORMAT A24;

SELECT  
    se.username || '(' || se.sid ||')' "User Session",
    SUM(DECODE(name, 'consistent gets',value, 0))  "Consistent Gets",
    SUM(DECODE(name, 'db block gets', value, 0))  "DB Block Gets",
    SUM(DECODE(name, 'physical reads', value, 0))  "Physical Reads",
    (SUM(DECODE(name, 'consistent gets', value, 0))  +
        SUM(DECODE(name, 'db block gets', value, 0))  -
        SUM(DECODE(name, 'physical reads', value, 0))) 
    /
    (SUM(DECODE(name, 'consistent gets',value, 0))  +
        SUM(DECODE(name, 'db block gets',value, 0))  )  * 100 "Hit Ratio" 
FROM  
    v$sesstat ss, 
    v$statname sn, 
    v$session se
WHERE   
    ss.sid = se.sid
    AND sn.statistic# = ss.statistic#
    AND value != 0
    AND sn.name IN (
        'db block gets', 
        'consistent gets', 
        'physical reads'
    )
GROUP BY 
    se.username, 
    se.sid
ORDER BY
    5
;
@_END
