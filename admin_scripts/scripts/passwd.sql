REM
REM  Change current user's password
REM  Author: Mark Lang, 1998
REM 

@_SET
SET SERVEROUTPUT ON SIZE 10240

PROMPT
PROMPT CHANGE CURRENT USER'S PASSWORD
PROMPT
ACCEPT passwd CHAR PROMPT "New password: " HIDE
ACCEPT verpwd CHAR PROMPT "Verify: " HIDE

DECLARE
    n NUMBER;
    cmd VARCHAR2(2000);

    FUNCTION exec(stmt VARCHAR2)
    RETURN NUMBER IS
        i NUMBER;
        retval NUMBER;
    BEGIN
    i := SYS.DBMS_SQL.OPEN_CURSOR;
    SYS.DBMS_SQL.PARSE(i, stmt, SYS.DBMS_SQL.V7);
    retval := SYS.DBMS_SQL.EXECUTE(i);
    SYS.DBMS_SQL.CLOSE_CURSOR(i);
    RETURN retval;
END;

BEGIN
    IF UPPER('&&passwd') = UPPER('&&verpwd') THEN
        cmd := 'ALTER USER ' || user || ' IDENTIFIED BY &&passwd';
        n := EXEC(cmd);
        IF n = 0 THEN
            SYS.DBMS_OUTPUT.PUT_LINE('Password changed.');
        ELSE
            SYS.DBMS_OUTPUT.PUT_LINE('An error occurred, password not changed.');
        END IF;
    ELSE
        SYS.DBMS_OUTPUT.PUT_LINE('Password was not correctly verified.');
    END IF;
END;
/

UNDEFINE passwd verpwd

@_DEFAULT

