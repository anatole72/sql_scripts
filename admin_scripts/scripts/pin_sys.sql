REM
REM  Pin some SYS packages in the shared pool.
REM
REM  NOTES:
REM  1. The script should be executed immediately after database startup.
REM  2. Execute the script as SYS.
REM  3. The script DBMSPOOL.SQL should be executed before in schema SYS.
REM
REM  Author: Mark Lang, 1998
REM 

SET SERVEROUTPUT ON

DECLARE
    PROCEDURE pin(p_name VARCHAR2)
    IS
    BEGIN
        DBMS_SHARED_POOL.KEEP(UPPER(p_name));
        DBMS_OUTPUT.PUT_LINE('Pinned: ' || UPPER(p_name));
    END;
BEGIN
    pin('standard');
    pin('diana');
    pin('diutil');
    -- add your own packages here!!!
END;
/


