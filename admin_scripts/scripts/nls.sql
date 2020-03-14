REM 
REM  Display NLS parameters
REM 

@_BEGIN
@_TITLE "NLS PARAMETERS"

COLUMN parameter        FORMAT A25
COLUMN database_value   FORMAT A15
COLUMN instance_value   FORMAT A15
COLUMN session_value    FORMAT A15

SELECT
    d.parameter,
    d.value database_value,
    i.value instance_value,
    s.value session_value
FROM
    nls_database_parameters d,
    nls_instance_parameters i,
    nls_session_parameters s
WHERE
    d.parameter = i.parameter(+)
    AND d.parameter = s.parameter(+)
;

@_END
