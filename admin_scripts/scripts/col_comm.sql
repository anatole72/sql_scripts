REM
REM  Comments on the table and its columns
REM

@_BEGIN

PROMPT
PROMPT COMMENTS ON THE TABLE AND ITS COLUMNS
PROMPT

ACCEPT tabown PROMPT "Table owner: "
ACCEPT tabname PROMPT "Table name: "

SET SERVEROUTPUT ON
DECLARE

    tabcomment	VARCHAR2(2000);
    colname	VARCHAR2(32);
    colcomment	VARCHAR2(2000);
    tab_name	VARCHAR2(32);

    CURSOR get_tab_com (tabo VARCHAR2, tabn VARCHAR2) IS
        SELECT  
            table_name,
            comments
        FROM  
            sys.dba_tab_comments
        WHERE  
            owner = UPPER(tabo)
            AND table_name = UPPER(tabn);


    CURSOR get_col_com (tabo VARCHAR2, tabn VARCHAR2) IS
        SELECT  
            column_name,
            comments
        FROM  
            sys.dba_col_comments
        WHERE  
            owner = UPPER(tabo)
            AND table_name = UPPER(tabn);

BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10));
    OPEN get_tab_com('&tabown', '&tabname');
    FETCH get_tab_com INTO tab_name, tabcomment;
    DBMS_OUTPUT.PUT_LINE(
        'Table:' || CHR(10) ||
        '------' || CHR(10) ||
        tab_name || ' - '  || tabcomment ||
        CHR(10) || CHR(10) ||
        'Columns:' || CHR(10) ||
        '--------');
    OPEN get_col_com('&tabown', '&tabname');
    LOOP 
        FETCH get_col_com INTO colname, colcomment;
        EXIT WHEN get_col_com%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(colname, 30) || ' - ' || colcomment);
    END LOOP;
    CLOSE get_tab_com;
    CLOSE get_col_com;
END;
/

@_END
