REM
REM  Display relationships between tables
REM  Author: Mark Lang, 1998
REM

@_BEGIN
SET SERVEROUTPUT ON SIZE 102400

PROMPT
PROMPT DISPLAY RELATIONSHIPS BETWEEN TABLES
PROMPT
PROMPT General format of output is:
PROMPT
PROMPT CHIELD.TABLE (opt|man) <REL> (opt|man) PARENT.TABLE
PROMPT
PROMPT where <REL> should be as follow:
PROMPT
PROMPT 1:1  one  to one, foreign key in primary key
PROMPT 1+1  one  to one, foreign key prefix of primary key
PROMPT M:1  many to one, foreign key in primary key
PROMPT M+1  many to one, foreign key prefix of primary key
PROMPT m:1  many to one, (normal)
PROMPT

ACCEPT o1 PROMPT "Child owner like (ENTER for all): "
DEFINE own1 = "NVL(UPPER('&&o1'), '%')"

ACCEPT n1 PROMPT "Child table like (ENTER for all): "
DEFINE nam1 = "NVL(UPPER('&&n1'), '%')"
PROMPT

ACCEPT o2 PROMPT "Parent owner like (ENTER for all): "
DEFINE own2 = "NVL(UPPER('&&o2'), '%')"

ACCEPT n2 PROMPT "Parent table like (ENTER for all): "
DEFINE nam2 = "NVL(UPPER('&&n2'), '%')"
PROMPT

DEFINE set1 = -
"SELECT column_name -
FROM sys.dba_cons_columns -
WHERE owner = r.owner -
AND constraint_name = r.constraint_name"

DEFINE set2 = -
"SELECT column_name -
FROM sys.dba_cons_columns -
WHERE owner=s.owner -
AND constraint_name = s.constraint_name"

DECLARE

    i NUMBER;
    m NUMBER;
    n NUMBER;
    num_cols NUMBER;
    num_null NUMBER;
    rel_type NUMBER;
    result VARCHAR2(255);

BEGIN
    FOR r IN (
        SELECT 
            c.*,
            r.table_name r_table_name,
            r.constraint_type r_constraint_type
        FROM
            sys.dba_constraints c,
            sys.dba_constraints r
        WHERE
            c.owner LIKE &&own1
            AND c.table_name LIKE &&nam1
            AND c.constraint_type = 'R'
            AND r.owner LIKE &&own2
            AND r.table_name LIKE &&nam2
            AND c.r_owner = r.owner
            AND c.r_constraint_name = r.constraint_name
        ORDER BY
            c.owner,
            c.table_name
    ) loop

        result := RPAD(r.owner || '.' || r.table_name, 30);

        SELECT COUNT(*), SUM(DECODE(t.nullable, 'Y', 1, 0))
        INTO num_cols, num_null
        FROM sys.dba_cons_columns c, sys.dba_tab_columns t
        WHERE c.owner = r.owner
        AND c.constraint_name = r.constraint_name
        AND c.owner = t.owner
        AND c.table_name = t.table_name
        AND c.column_name = t.column_name;

        FOR s IN (
            SELECT *
            FROM sys.dba_constraints c
            WHERE c.owner = r.owner
            AND c.table_name = r.table_name
            AND c.constraint_type in ('P', 'U')
        ) LOOP
            rel_type := 0;

            SELECT COUNT(*) -- is part of UNIQUE or PRIMARY key
            INTO n
            FROM dual
            WHERE EXISTS (
                &&set1
                MINUS
                &&set2
            );

            IF n = 0 THEN
                IF s.constraint_type = 'P' THEN
                    rel_type := 2;
                ELSE
                    rel_type := 1;
                END IF;

                SELECT COUNT(*) -- is one-to-one
                INTO m
                FROM DUAL
                WHERE EXISTS (
                    &&set2
                    MINUS
                    &&set1
                );

                IF m = 0 THEN
                    IF s.constraint_type = 'P' THEN
                        rel_type := 4;
                    ELSE
                        rel_type := 3;
                    END IF;
                    EXIT;
                END IF;
            END IF;

        END LOOP;

        IF num_null > 0 THEN
            result := result || ' (opt)';
        ELSE
            result := result || ' (man)';
        END IF;

        IF rel_type = 4 THEN result := result || ' 1+1';
        ELSIF rel_type = 3 THEN result := result || ' 1:1';
        ELSIF rel_type = 2 THEN result := result || ' M+1';
        ELSIF rel_type = 1 THEN result := result || ' M:1';
        ELSE result := result || ' m:1';
        END IF;

        result := result || ' (opt)';
        result := result || ' ' || RPAD(r.r_owner || '.' || r.r_table_name, 30);

        SYS.DBMS_OUTPUT.PUT_LINE(result);
    END LOOP;
END;
/

UNDEFINE o1 own1 n1 nam1 o2 own2 n2 nam2 set1 set2

@_END




