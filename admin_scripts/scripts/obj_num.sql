REM
REM  Statement to determine object info from an object number.
REM  Easily customized and can be used in analyzing ORA-600 object
REM  level errors.
REM
REM  The script should be executed as SYS.
REM

@_BEGIN

PROMPT
PROMPT DETERMINING OBJECT INFO FROM AN OBJECT NUMBER
PROMPT
ACCEPT num PROMPT "Object number: " NUMBER

SET SERVEROUTPUT ON;
DECLARE
    v_name      VARCHAR2(50);
    v_obj       NUMBER := &&num;
    v_blockno   NUMBER;
    v_fileno    NUMBER;
    CURSOR c1 (p_obj NUMBER) IS
        SELECT file#, block#
        FROM tab$
        WHERE obj# = p_obj;
BEGIN
    SELECT u.name || '.' || o.name
    INTO v_name 
    FROM obj$ o, user$ u
    WHERE o.owner# = u.user#
    AND o.obj# = v_obj;

    DBMS_OUTPUT.PUT_LINE('Object: ' || v_name);

    OPEN c1 (v_obj);
    LOOP
        FETCH c1 INTO v_fileno, v_blockno;
        EXIT WHEN c1%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('File: ' || v_fileno || ' Block: ' || v_blockno); 
    END LOOP;
    CLOSE c1;
END;
/
@_END
