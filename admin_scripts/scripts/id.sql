REM
REM  Display current username and database
REM

@_SET
SET PAGESIZE 0
SET TERMOUT OFF
SELECT '' FROM DUAL;
SET TERMOUT ON
SELECT 'Connected as ' || USER || ' to ' || global_name FROM global_name;
@_DEFAULT

