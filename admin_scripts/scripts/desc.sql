REM 
REM  Enhanced sql*plus-like describe for tables
REM 
REM  Like sql*plus describe but includes key/index information as Pn(m)
REM  where "P" is type of key (P=primary, U=unique, R=foreign, B=bitmap,
REM  I=index), "n" is nth key of same type (for reference), "m" - column
REM  position in key.
REM  
REM  Author:  Mark Lang, 1998
REM

@_BEGIN

PROMPT
PROMPT ENHANCED SQL*PLUS-LIKE DESCRIBE FOR TABLES
PROMPT

ACCEPT own PROMPT "Table (view) owner like (ENTER for all): "
DEFINE town = "NVL(UPPER('&&own'), '%')"

ACCEPT nam PROMPT "Table (view) name like (ENTER for all): "
DEFINE tnam = "NVL(UPPER('&&nam'), '%')"

REM What to show in output? (PURIB%-)
DEFINE keys = "'PURIB'"

ACCEPT siz PROMPT "Buffer size (ENTER for 10240): " NUMBER
@_HIDE
COLUMN siz NEW_VALUE size NOPRINT
SELECT DECODE(&siz, 0, 10240, &siz) siz FROM sys.dual;
SET SERVEROUTPUT ON SIZE &size
@_SET
PROMPT

DECLARE

PROCEDURE describe(town VARCHAR2, tnam VARCHAR2) IS

    c1 NUMBER := 27;
    c2 NUMBER := 8;
    c3 NUMBER := 15;
    c4 NUMBER := 25;

    TYPE keyrec_t IS RECORD (
        nam VARCHAR2(30),
        typ CHAR(1),
        pos NUMBER
    );

    TYPE keytab_t IS TABLE OF keyrec_t INDEX BY BINARY_INTEGER;

    TYPE colrec_t IS RECORD (
        nam VARCHAR2(30),
        pos NUMBER,
        key BINARY_INTEGER
    );

    TYPE coltab_t IS TABLE OF colrec_t INDEX BY BINARY_INTEGER;

    keytab keytab_t;
    coltab coltab_t;

    keynum BINARY_INTEGER := 0;
    colnum BINARY_INTEGER := 0;

    pnum BINARY_INTEGER := 0;
    unum BINARY_INTEGER := 0;
    rnum BINARY_INTEGER := 0;
    inum BINARY_INTEGER := 0;
    bnum BINARY_INTEGER := 0;

    i BINARY_INTEGER;
    n BINARY_INTEGER;
    c VARCHAR2(2);

    txt VARCHAR2(512);

    PROCEDURE get_con_cols IS
    BEGIN

        FOR r IN (
            SELECT *
            FROM dba_constraints
            WHERE owner = town
            AND table_name = tnam
            AND constraint_type IN ('P', 'U', 'R')
            ORDER BY DECODE(constraint_type, 'P', 1, 'U', 2, 'R', 3, 4)
        ) LOOP

            keynum := keynum + 1;
            keytab(keynum).nam := r.constraint_name;
            IF r.constraint_type = 'P' THEN
                pnum := pnum + 1;
                n := pnum;
                c := 'P';
            ELSIF r.constraint_type = 'U' THEN
                unum := unum + 1;
                n := unum;
                c := 'U';
            ELSE
                rnum := rnum + 1;
                n := rnum;
                c := 'R';
            END IF;
            keytab(keynum).typ := c;
            keytab(keynum).pos := n;

            FOR s IN (
                SELECT *
                FROM dba_cons_columns
                WHERE owner = r.owner
                AND constraint_name = r.constraint_name
                ORDER BY position
            ) LOOP
                colnum := colnum + 1;
                coltab(colnum).key := keynum;
                coltab(colnum).nam := s.column_name;
                coltab(colnum).pos := s.position;
            END LOOP;

        END LOOP;
    END;

    PROCEDURE get_ind_cols IS
    BEGIN

        FOR r IN (
            SELECT *
            FROM dba_indexes i
            WHERE table_owner = town
            AND table_name = tnam
            AND NOT EXISTS (
                SELECT 0
                FROM all_constraints
                WHERE owner = i.table_owner
                AND constraint_name = i.index_name
            )
            ORDER BY DECODE(uniqueness, 'UNIQUE', 1, 'BITMAP', 3, 2)
        ) LOOP

            keynum := keynum + 1;
            keytab(keynum).nam := r.index_name;
            IF r.uniqueness = 'UNIQUE' THEN
                unum := unum + 1;
                n := unum;
                c := 'U';
            ELSIF r.uniqueness = 'BITMAP' THEN
                bnum := bnum + 1;
                n := bnum;
                c := 'B';
            ELSE
                inum := inum + 1;
                n := inum;
                c := 'I';
            END IF;
            keytab(keynum).typ := c;
            keytab(keynum).pos := n;

            FOR s IN (
                SELECT *
                FROM dba_ind_columns
                WHERE index_owner = r.owner
                AND index_name = r.index_name
                ORDER BY column_position
            ) LOOP
                colnum := colnum + 1;
                coltab(colnum).key := keynum;
                coltab(colnum).nam := s.column_name;
                coltab(colnum).pos := s.column_position;
            END LOOP;
            
        END LOOP;
    END;

BEGIN

    IF &&keys != '-' AND NVL(LENGTH(&&keys), 0) > 0 THEN
        get_con_cols;
        get_ind_cols;
    END IF;

    DBMS_OUTPUT.PUT_LINE(
        RPAD('COLUMN_NAME', c1) || ' '
        || RPAD('NULL?', c2) || ' '
        || RPAD('TYPE', c3) || ' '
        || RPAD('KEYS', c4)
    );

    DBMS_OUTPUT.PUT_LINE(
        RPAD('-', c1, '-') || ' '
        || RPAD('-', c2, '-') || ' '
        || RPAD('-', c3, '-') || ' '
        || RPAD('-', c4, '-')
    );

    FOR r IN (
        SELECT
            column_name d_name,
            DECODE(nullable, 'N', 'NOT NULL', ' ') d_null,
            data_type || DECODE(DECODE(data_type, 'FLOAT', 'NUMBER', data_type),
            'DATE',
            '',
            'NUMBER',
            DECODE(data_precision, NULL, '', '(' || TO_CHAR(data_precision)
                || DECODE(data_scale, NULL, '', 0, '', ',' || TO_CHAR(data_scale)) || ')'),
            DECODE(data_length, NULL, '', 0, '', '('
                || TO_CHAR(data_length) || ')')) d_type
        FROM all_tab_columns
        WHERE owner = town
        AND table_name = tnam
    ) LOOP
        txt := RPAD(r.d_name, c1) || ' '
            || RPAD(r.d_null, c2) || ' '
            || RPAD(r.d_type, c3) || ' ';
        FOR i IN 1..colnum LOOP
            IF coltab(i).nam = r.d_name THEN
                n := coltab(i).key;
                IF INSTR(&&keys, keytab(n).typ) > 0 THEN
                    txt := txt || RPAD(keytab(n).typ || TO_CHAR(keytab(n).pos)
                        || '(' || TO_CHAR(coltab(i).pos) || ')', 6);
                END IF;
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(txt);
    END LOOP;
END;

BEGIN
    FOR r IN (
        SELECT *
        FROM dba_objects
        WHERE owner LIKE &&town
        AND object_name LIKE &&tnam
        AND object_type IN ('TABLE', 'VIEW')
        ORDER BY owner, object_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(r.object_type || ' ' || r.owner || '.' || r.object_name);
        DESCRIBE(r.owner, r.object_name);
        DBMS_OUTPUT.PUT_LINE(CHR(10));
    END LOOP;
END;
/

UNDEFINE own town nam tnam keys siz size

@_END
