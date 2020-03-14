REM
REM  Script for documenting relationships among tables of a user  
REM
REM  NOTES: This script is intended to run with Oracle7.
REM

PROMPT
PROMPT RELATIONSHIPS AMONG TABLES OF A USER
PROMPT
ACCEPT schema PROMPT "Schema: "

@_SET
@_HIDE
SET LONG 4000 

CREATE TABLE temp$constraint (
    owner                   VARCHAR2(30),
    constraint_name         VARCHAR2(30),
    constraint_type         VARCHAR2(11),
    search_condition        VARCHAR2(2000),
    table_name              VARCHAR2(30),
    referenced_owner        VARCHAR2(30),
    referenced_constraint   VARCHAR2(30),
    delete_rule             VARCHAR2(9),
    constraint_columns      VARCHAR2(2000),
    con_number              NUMBER
); 

DECLARE 
    CURSOR cons_cursor IS 
        SELECT	
            owner,
            constraint_name, 
            DECODE(constraint_type,
                'P', 'Primary Key',
                'R', 'Foreign Key'),
            table_name,
            search_condition, 
            r_owner,
            r_constraint_name,
            delete_rule
        FROM 
            dba_constraints 
        WHERE 
            owner = UPPER('&schema') 
            AND constraint_type in ('P','R')
     	ORDER BY 
            owner
        ; 

    CURSOR cons_col (cons_name IN VARCHAR2) IS 
        SELECT 
            owner,
            constraint_name,
            column_name
        FROM 
            dba_cons_columns 
        WHERE 
            owner = UPPER('&schema') 
            AND constraint_name = cons_name
        ORDER BY 
            owner, 
            constraint_name, 
            position
        ;

    CURSOR get_cons (tab_nam IN VARCHAR2) IS
        SELECT DISTINCT 
            owner,
            table_name,
            constraint_name,
            constraint_type
        FROM 
            temp$constraint
        WHERE 
            table_name = tab_nam
            AND constraint_type = 'Foreign Key'
        ORDER BY 
            owner,
            table_name,
            constraint_name
        ;

    CURSOR get_tab_nam IS
        SELECT DISTINCT table_name
        FROM temp$constraint
        WHERE constraint_type = 'Foreign Key'
        ORDER BY table_name;

    tab_nam         dba_constraints.table_name%TYPE;
    cons_owner      dba_constraints.owner%TYPE;
    cons_name       dba_constraints.constraint_name%TYPE;
    cons_type       VARCHAR2(11);
    cons_sc         dba_constraints.search_condition%TYPE;
    cons_tname      dba_constraints.table_name%TYPE;
    cons_rowner     dba_constraints.r_owner%TYPE;
    cons_rcons      dba_constraints.r_constraint_name%TYPE;
    cons_dr         dba_constraints.delete_rule%TYPE;   
    cons_col_own    dba_cons_columns.owner%TYPE;
    cons_col_nam    dba_cons_columns.constraint_name%TYPE;
    cons_column     dba_cons_columns.column_name%TYPE;
    cons_tcol_name  dba_cons_columns.table_name%TYPE;
    all_columns     VARCHAR2(2000);
    counter         INTEGER := 0;
    cons_nbr        INTEGER;

BEGIN
    OPEN cons_cursor;
    LOOP
        FETCH cons_cursor 
        INTO
            cons_owner,
            cons_name,
            cons_type,
            cons_sc,
            cons_tname,
            cons_rowner,
            cons_rcons,
            cons_dr
        ;
        EXIT WHEN cons_cursor%NOTFOUND;

    	all_columns := '';	
    	counter := 0;
    	OPEN cons_col(cons_name);
        LOOP
            FETCH cons_col INTO
                cons_col_own,
                cons_col_nam,
                cons_column
            ;
            EXIT WHEN cons_col%NOTFOUND; 
            IF cons_owner = cons_col_own AND cons_name = cons_col_nam THEN
                counter := counter + 1;
                IF counter = 1 THEN
                    all_columns := all_columns || cons_column;
                ELSE
                    all_columns := all_columns || ', ' || cons_column;
                END IF;
            END IF;
        END LOOP;
        CLOSE cons_col;

    	INSERT INTO temp$constraint VALUES (
                cons_owner,
                cons_name,
                cons_type,
                cons_tname,
                cons_sc,
                cons_rowner,
                cons_rcons,
                cons_dr,
                all_columns,
                0);
        COMMIT;
    END LOOP;
    CLOSE cons_cursor;
    COMMIT;

    BEGIN
        OPEN get_tab_nam;
        LOOP
            FETCH get_tab_nam INTO tab_nam;
            EXIT WHEN get_tab_nam%NOTFOUND;
            OPEN get_cons(tab_nam);
            cons_nbr := 0;
            LOOP
                FETCH get_cons 
                    INTO cons_owner, cons_tname, cons_name, cons_type;
                EXIT WHEN get_cons%NOTFOUND;
                cons_nbr := cons_nbr + 1;

                UPDATE temp$constraint 
                SET con_number = cons_nbr 
                WHERE constraint_name = cons_name 
                    AND constraint_type = cons_type 
                    AND owner = cons_owner
                ;
            END LOOP;
            CLOSE get_cons;
            COMMIT;
        END LOOP;
        CLOSE get_tab_nam;
        COMMIT;
    END;
END;
/

CREATE INDEX pk_temp$constraint ON temp$constraint(constraint_name);
CREATE INDEX lk_temp$constraint ON temp$constraint(constraint_type);
CREATE INDEX lk_temp$constraint2 ON temp$constraint(referenced_constraint);

@_BEGIN
@_WTITLE "&&schema''S TABLE RELATIONSHIPS REPORT"
SET ARRAYSIZE 1

COLUMN pk           FORMAT A19 HEADING 'Primary Key|Constraint'
COLUMN fk           FORMAT A25 HEADING 'Foreign Key|Constraint'
COLUMN pk_tab       FORMAT A21 HEADING 'Parent Table|Name'
COLUMN fk_tab       FORMAT A21 HEADING 'Child Table|Name'
COLUMN refered_to   FORMAT A20 HEADING 'Columns|Referred To' WORD_WRAPPED
COLUMN referring    FORMAT A20 HEADING 'Columns|Referring' WORD_WRAPPED
BREAK ON pk ON pk_tab ON refered_to 

SELECT
    b.constraint_name pk,
    b.table_name pk_tab,
    b.constraint_columns refered_to,
    a.constraint_name fk,
    a.table_name fk_tab,
    a.constraint_columns referring
FROM 
    temp$constraint a, 
    temp$constraint b 
WHERE 
    b.constraint_name = a.referenced_constraint
    AND a.constraint_type = 'Foreign Key'
ORDER BY 
    b.constraint_name, 
    b.table_name, 
    b.constraint_columns
/

@_HIDE
drop table temp$constraint;
UNDEFINE schema
@_SET
@_END

