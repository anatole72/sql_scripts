REM
REM The script builds a standart report heading for database reports
REM that are 132 columns
REM

COLUMN title_    NEW_VALUE heading_      NOPRINT
COLUMN today_    NEW_VALUE current_date_ NOPRINT
COLUMN time_     NEW_VALUE current_time_ NOPRINT
COLUMN user_db_  NEW_VALUE current_user_ NOPRINT

SET PAGESIZE 0
SET LINESIZE 132
SELECT UPPER('&1') title_ FROM sys.dual;
@_SET

TTITLE -
   LEFT "***********************************************************************************************************************************" SKIP -
   LEFT "Date: " current_date_ -
   RIGHT current_user_ SKIP -
   LEFT "Time: " current_time_ -
   CENTER heading_ -
   COL 123 "Page:" FORMAT 999 SQL.PNO SKIP - 
   LEFT "***********************************************************************************************************************************" SKIP 2

SET HEADING OFF
SET TERMOUT OFF
SET PAGESIZE 0

SELECT
   TO_CHAR(SYSDATE, 'DD/MM/YY') today_,
   TO_CHAR(SYSDATE, 'HH24:MI')  time_,
   USER || '@' || name || ' ' user_db_
FROM
   sys.dual,
   v$database
;

@_SET

