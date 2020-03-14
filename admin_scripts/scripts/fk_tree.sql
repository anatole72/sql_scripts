REM 
REM  Display FK references in tree format.
REM  Author:  Mark Lang, 1998
REM  

@_BEGIN
SET SERVEROUTPUT ON SIZE 10240

PROMPT
PROMPT FOREIGN KEY REFERENCES IN TREE FORMAT
PROMPT

ACCEPT o PROMPT "Table owner like (ENTER for all): "
DEFINE own = "NVL(UPPER('&&o'), '%')"

ACCEPT n PROMPT "Table name like (ENTER for all): "
DEFINE nam = "NVL(UPPER('&&n'), '%')"

PROMPT
PROMPT If reference count >=0 then table must have no more than N refs.
PROMPT If reference count < 0 then table must have less than N refs.

ACCEPT c PROMPT "Reference count (ENTER for 99): "
DEFINE cnt = "DECODE('&&c', '', 99, TO_NUMBER('&&c'))"

PROMPT
PROMPT If level > 0 then display N refs.
PROMPT If level = 0 then display all refs.
PROMPT If level < 0 then display inverse to N levels.

ACCEPT l PROMPT "Level (ENTER for 0): "
DEFINE lvl = "DECODE('&&l', '', 0, TO_NUMBER('&&l'))"
PROMPT

DECLARE

    n_own NUMBER;
    n_obj NUMBER;
    n_lvl NUMBER;
    v_text VARCHAR2(240);

    FUNCTION get_obj_name(n_obj NUMBER)
    RETURN VARCHAR2
    IS
        retval VARCHAR2(60);
    BEGIN
        SELECT u.name || '.' || o.name
        INTO retval
        FROM sys.obj$ o, sys.user$ u
        WHERE o.obj# = n_obj
        AND o.owner# = u.user#;
        RETURN retval;
    END;

    PROCEDURE get_refs(n_obj NUMBER, n_level NUMBER)
    IS
    BEGIN
        IF n_level > ABS(n_lvl) AND ABS(n_lvl) > 0 THEN
            RETURN;
        END IF;

        IF n_lvl >= 0 THEN
            FOR p IN (
	            SELECT *
	            FROM sys.cdef$
	            WHERE obj# = n_obj
	            AND type IN (2, 3) -- PK and UK
            ) LOOP
	            FOR r IN (
	                SELECT *
	                FROM sys.cdef$
	                WHERE robj# = p.obj#
	                AND rcon# = p.con#
	            ) LOOP
	                SYS.DBMS_OUTPUT.PUT_LINE(RPAD('.', n_level * 2)
	                    || get_obj_name(r.obj#)
	                );
	                get_refs(r.obj#, n_level + 1);
	            END LOOP;
            END LOOP;
        ELSE
            FOR p IN (
	            SELECT *
	            FROM sys.cdef$
	            WHERE obj# = n_obj
	            AND type = 4 -- FK
            ) LOOP
	            FOR r IN (
	                SELECT *
	                FROM sys.cdef$
	                WHERE robj# = p.obj#
	                AND rcon# = p.con#
	            ) LOOP
	                SYS.DBMS_OUTPUT.PUT_LINE(RPAD('.', n_level * 2)
	                    || get_obj_name(r.obj#)
	                );
	                get_refs(r.obj#, n_level + 1);
	            END LOOP;
            END LOOP;
        END IF;
    END; 

BEGIN

    SELECT &&lvl
    INTO n_lvl
    FROM sys.dual;

    FOR r IN (
        SELECT obj#
        FROM sys.obj$ o, sys.user$ u
        WHERE o.owner# = u.user#
        AND u.name LIKE &&own
        AND o.name LIKE &&nam
        AND o.type = 2 -- TABLE
        AND (
            (&&cnt >= 0 AND &&cnt >= (
	            SELECT COUNT(*)
	            FROM sys.cdef$
	            WHERE robj# = o.obj#
	            AND type = 4
	            )
	        )
            OR
            (&&cnt < 0 AND &&cnt > (
	            SELECT count(*)
	            FROM sys.cdef$
	            WHERE robj# = o.obj#
	            AND type = 4
                )
            )
        )
    ) LOOP
        SYS.DBMS_OUTPUT.PUT_LINE(get_obj_name(r.obj#));
        get_refs(r.obj#, 1);
    END LOOP;
   
END;
/

UNDEFINE o own
UNDEFINE n nam
UNDEFINE c cnt
UNDEFINE l lvl

@_END

