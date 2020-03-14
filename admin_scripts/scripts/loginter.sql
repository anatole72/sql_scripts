REM
REM This script displays summary info about intervals between redo
REM log switches by days.
REM
REM December 2, 1997
REM 

@_BEGIN
@_TITLE "LOG SWITCH INTERVALS BY DAY (IN MINUTES)"

COLUMN "Date"                       FORMAT A12
COLUMN "Switches"                   FORMAT 9999
COLUMN avg HEADING "Average Time"   FORMAT 9999.0
COLUMN min HEADING "Minimum Time"   FORMAT 9999.0
COLUMN max HEADING "Maximum Time"   FORMAT 9999.0
COLUMN dev HEADING "Deviation"      FORMAT 9999.0

SELECT 
   TO_CHAR(TO_DATE(SUBSTR(L1.Time, 1, 8), 'MM/DD/YY'), 
      'DD-MON-YYYY') "Date",
   COUNT (1) "Switches",
   AVG((TO_DATE(L2.Time, 'MM/DD/YY HH24:MI:SS') -
      TO_DATE(L1.Time, 'MM/DD/YY HH24:MI:SS')) * 24 * 60) avg,
   MIN((TO_DATE(L2.Time, 'MM/DD/YY HH24:MI:SS') -
      TO_DATE(L1.Time, 'MM/DD/YY HH24:MI:SS')) * 24 * 60) min,
   MAX((TO_DATE(L2.Time, 'MM/DD/YY HH24:MI:SS') -
      TO_DATE(L1.Time, 'MM/DD/YY HH24:MI:SS')) * 24 * 60) max,
   STDDEV((TO_DATE(L2.Time, 'MM/DD/YY HH24:MI:SS') -
      TO_DATE(L1.Time, 'MM/DD/YY HH24:MI:SS')) * 24 * 60) dev
FROM
   v$log_history l1,
   v$log_history l2
WHERE
   l1.sequence# = l2.sequence# - 1 
   AND SUBSTR(L1.Time, 1, 8) = SUBSTR(L2.Time, 1, 8)
GROUP BY
   SUBSTR(L1.Time, 1, 8)
ORDER BY
   TO_DATE(SUBSTR(L1.Time, 1, 8), 'MM/DD/YY') DESC
;   

@_END

