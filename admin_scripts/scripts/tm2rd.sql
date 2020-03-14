REM
REM  Converts a standard date into redo dump time format.
REM

@_BEGIN

PROMPT
PROMPT CONVERTS MM/DD/YYYY HH:MI:SS TO REDO DUMP TIME
PROMPT

ACCEPT redo_day     PROMPT "Enter day (DD/MM/YYYY): "
ACCEPT redo_hhmiss  PROMPT "Enter time (HH24:MI:SS): "

COLUMN redo_year  NEW_VALUE redo_year   FORMAT 9999
COLUMN redo_month NEW_VALUE redo_month  FORMAT 9999
COLUMN redo_day   NEW_VALUE redo_day    FORMAT 9999
COLUMN redo_hour  NEW_VALUE redo_hour   FORMAT 9999
COLUMN redo_min   NEW_VALUE redo_min    FORMAT 9999
COLUMN redo_sec   NEW_VALUE redo_sec    FORMAT 9999
COLUMN redo_time  NEW_VALUE redo_time   FORMAT 9999999999

SELECT
    TO_NUMBER(TO_CHAR(TO_DATE('&redo_day &redo_hhmiss',
        'DD/MM/YYYY HH24:MI:SS'),'YYYY')) redo_year,
    TO_NUMBER(TO_CHAR(TO_DATE('&redo_day &redo_hhmiss',
        'DD/MM/YYYY HH24:MI:SS'),'MM'))   redo_month,
    TO_NUMBER(TO_CHAR(TO_DATE('&redo_day &redo_hhmiss',
        'DD/MM/YYYY HH24:MI:SS'),'DD'))   redo_day,
    TO_NUMBER(TO_CHAR(TO_DATE('&redo_day &redo_hhmiss',
        'DD/MM/YYYY HH24:MI:SS'),'HH24')) redo_hour,
    TO_NUMBER(TO_CHAR(TO_DATE('&redo_day &redo_hhmiss',
        'DD/MM/YYYY HH24:MI:SS'),'MI'))   redo_min,
    TO_NUMBER(TO_CHAR(TO_DATE('&redo_day &redo_hhmiss',
        'DD/MM/YYYY HH24:MI:SS'),'SS'))   redo_sec
FROM dual;

SELECT
    ((((((&redo_year - 1988)) * 12
        + (&redo_month - 1)) * 31
        + (&redo_day - 1)) * 24
        + (&redo_hour)) * 60
        + (&redo_min)) * 60
        + (&redo_sec) redo_time
FROM DUAL;

UNDEFINE redo_day redo_hhmiss redo_year redo_month
UNDEFINE redo_day redo_hour redo_min redo_sec

@_END

