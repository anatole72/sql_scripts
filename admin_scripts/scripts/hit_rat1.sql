REM
REM  Cumulative hit ratio since startup
REM

@_BEGIN
@_TITLE "CUMULATIVE HIT RATIO"
SELECT 
   SUM(DECODE(Name, 'consistent gets', Value, 0)) "Consistent Gets",
   SUM(DECODE(Name, 'db block gets', Value, 0)) "DB Block Gets",
   SUM(DECODE(Name, 'physical reads', Value, 0)) "Physical Reads",
   ROUND(((SUM(DECODE(Name, 'consistent gets', Value, 0)) +
      SUM(DECODE(Name, 'db block gets', Value, 0)) -
      SUM(DECODE(Name, 'physical reads', Value, 0)) ) /
      (SUM(DECODE(Name, 'consistent gets', Value, 0)) +
      SUM(DECODE(Name, 'db block gets', Value, 0)))) 
      * 100, 2) "HIT RATIO (%)"
FROM
   v$sysstat
;
@_END
