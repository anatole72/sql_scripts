REM
REM  This will report all events set in the current session and
REM  their level.
REM
REM  The script must be run as SYS
REM 

@_BEGIN
SET SERVEROUTPUT ON
PROMPT

DECLARE
    event_level NUMBER;
BEGIN
    FOR i IN 10000..10999 LOOP
        DBMS_SYSTEM.READ_EV(i, event_level);
        IF (event_level > 0) THEN
            DBMS_OUTPUT.PUT_LINE('Event ' || TO_CHAR(i) || ' set at level ' ||
                TO_CHAR(event_level));
        END IF;
    END LOOP;
END;
/
@_END
