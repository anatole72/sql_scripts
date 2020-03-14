REM 
REM  Report summary of triggers by type and event
REM 

PROMPT
PROMPT SUMMARY OF TRIGGERS BY TYPE AND EVENT
PROMPT
ACCEPT own PROMPT "Owner name like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "

@_BEGIN
@_TITLE "SUMMARY OF TRIGGERS BY TYPE AND EVENT"

SELECT
    trigger_type,
    triggering_event,
    SUM(DECODE(status, 'ENABLED', 1, 0)) enabled,
    SUM(DECODE(status, 'ENABLED', 0, 1)) disabled  
FROM
    all_triggers
WHERE
    owner LIKE NVL(UPPER('&&own'), '%')
    AND table_name LIKE NVL(UPPER('&&nam'), '%')
GROUP BY
    trigger_type,
    triggering_event
;

UNDEFINE own nam
@_END

