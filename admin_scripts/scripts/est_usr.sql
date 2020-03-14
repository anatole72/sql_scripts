REM 
REM  Estimate objects in a schema by DBMS_UTILITY
REM
REM  Author:  Mark Lang, 1998
REM

PROMPT
PROMPT ESTIMATE OBJECTS IN A SCHEMA USING DBMS_UTILITY
PROMPT
ACCEPT usr PROMPT "Schema: "
ACCEPT sam PROMPT "Sample rows (0 if default, -
1..100 if %, >100 if rows): " NUMBER
PROMPT

SET SERVEROUTPUT ON
@_BEGIN

DECLARE

    i BINARY_INTEGER;
    sam NUMBER;
    row NUMBER;
    pct NUMBER;
    txt VARCHAR2(30);
    opt VARCHAR2(60);
    tim VARCHAR2(30);
    t1 NUMBER;
    t2 NUMBER;

BEGIN

    sam := &&sam;
    IF sam > 100 THEN
        row := sam;
        txt := 'rows';
    ELSIF sam > 0 THEN
        pct := sam;
        txt := '%';
    END IF;

    FOR i IN 1..3 LOOP
        IF i = 1 THEN
            opt := 'for table';
        ELSIF i = 2 THEN
            opt := 'for all indexes';
        ELSE
            opt := 'for all indexed columns';
        END IF;
        t1 := SYS.DBMS_UTILITY.GET_TIME;
        SYS.DBMS_UTILITY.ANALYZE_SCHEMA (
            schema => UPPER('&&usr'),
            method => 'ESTIMATE',
            estimate_rows => row,
            estimate_percent => pct,
            method_opt => opt
        );
        t2 := SYS.DBMS_UTILITY.GET_TIME;
        tim := ' (' || LTRIM(TO_CHAR((t2 - t1) / (100 * 60), '990.90')) || ' min)';
        IF sam > 0 THEN
            SYS.DBMS_OUTPUT.PUT_LINE('Estimate ' || opt || ' (' || TO_CHAR(sam)
                || ' ' || txt || ') on ' || UPPER('&&usr') || tim);
        ELSE
            SYS.DBMS_OUTPUT.PUT_LINE('Estimate ' || opt || ' on ' || UPPER('&&usr') || tim);
        END IF;
    END LOOP;
END;
/

UNDEFINE USR SAM

@_END



