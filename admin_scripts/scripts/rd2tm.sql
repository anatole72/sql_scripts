REM
REM  The script converts time from a redo dump into a readable format.
REM

@_BEGIN

PROMPT
PROMPT CONVERTS TIME FROM A REDO DUMP INTO A READABLE FORMAT
PROMPT

ACCEPT redo_time PROMPT "Enter redo time: "

COLUMN redo_year  NEW_VALUE redo_year   FORMAT 9999
COLUMN redo_month NEW_VALUE redo_month  FORMAT 9999
COLUMN redo_day   NEW_VALUE redo_day    FORMAT 9999
COLUMN redo_hour  NEW_VALUE redo_hour   FORMAT 9999
COLUMN redo_min   NEW_VALUE redo_min    FORMAT 9999
COLUMN redo_sec   NEW_VALUE redo_sec    FORMAT 9999

SELECT
    TRUNC(TRUNC(TRUNC(TRUNC(TRUNC(&redo_time/60)/60)/24)/31)/12)+1988 redo_year,
    MOD(TRUNC(TRUNC(TRUNC(TRUNC(&redo_time/60)/60)/24)/31),12)+1      redo_month,
    MOD(TRUNC(TRUNC(TRUNC(&redo_time/60)/60)/24),31)+1                redo_day,
    MOD(TRUNC(TRUNC(&redo_time/60)/60),24)                            redo_hour,
    MOD(TRUNC(&redo_time/60),60)                                      redo_min,
    MOD(&redo_time,60)                                                redo_sec
FROM DUAL;

UNDEFINE redo_time redo_year redo_month redo_day redo_hour redo_min redo_sec   

@_END
