REM
REM  Report on all triggers and their status.
REM

PROMPT
PROMPT TRIGGERS AND THEIR STATUS
PROMPT

ACCEPT tow PROMPT "Trigger owner like (ENTER for all): "
ACCEPT tna PROMPT "Trigger name like (ENTER for all): "
ACCEPT own PROMPT "Table owner like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "

@_BEGIN
@_WTITLE "TRIGGER STATUS REPORT"

COLUMN owner            FORMAT A20
COLUMN trigger_name     FORMAT A20  HEADING "Trigger"
COLUMN trigger_type     FORMAT A20  HEADING "Type"
COLUMN triggering_event FORMAT A18  HEADING "Event"
COLUMN table            FORMAT A40  HEADING "Trigger Table"
BREAK ON owner SKIP 1

SELECT  
    owner, 
    trigger_name,
    trigger_type,
    triggering_event,
    table_owner || '.' || table_name "Table", 
    status 
FROM
    dba_triggers
WHERE
    owner LIKE NVL(UPPER('&tow'), '%')
    AND trigger_name LIKE NVL(UPPER('&tna'), '%')
    AND table_owner LIKE NVL(UPPER('&own'), '%')
    AND table_name LIKE NVL(UPPER('&nam'), '%')
ORDER BY
    1, 5, 2
;

UNDEFINE tow tna own nam

@_END
