REM 
REM  Resolve reference to specified name from current account
REM  (tells you what object name actually refers to).
REM 
REM  Resolution stops if object is in another database.
REM  
REM  Author: Mark Lang, 1998
REM

@_BEGIN

PROMPT
PROMPT RESOLVE REFERENCE TO SPECIFIED NAME FROM CURRENT ACCOUNT
PROMPT
ACCEPT nam PROMPT "Object name: "

SET HEADING OFF

VARIABLE result VARCHAR2(80)

DECLARE
    a       VARCHAR2(30);
    b       VARCHAR2(30);
    c       VARCHAR2(30);
    dblink  VARCHAR2(128);
    nextpos NUMBER;

    FUNCTION dig_it (v_owner VARCHAR2, v_name VARCHAR2)
    RETURN VARCHAR2 IS
        r all_objects%ROWTYPE;
        s all_synonyms%ROWTYPE;
        p VARCHAR2(30);
    BEGIN

        IF v_owner IS NULL OR v_name IS NULL THEN
            RETURN '';
        END IF;

        BEGIN
            SELECT * INTO s
            FROM all_synonyms
            WHERE owner = v_owner
            AND synonym_name = v_name;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                BEGIN
                    SELECT * INTO r
                    FROM all_objects
                    WHERE owner = v_owner
                    AND object_name = v_name
                    AND rownum = 1;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        RETURN NULL;
                END;
                RETURN r.owner || '.' || r.object_name || ' (' || r.object_type || ')';
        END;

        IF s.db_link IS NOT NULL THEN
            RETURN s.owner || '.' || s.synonym_name ||
                ' => ' || NVL(s.table_owner, '?') ||
                '.' || s.table_name || '@' || s.db_link || ' (???)';
        ELSE
            RETURN v_owner || '.' || v_name ||
                ' => ' || dig_it(s.table_owner, s.table_name);
        END IF;
    END;

BEGIN

    DBMS_UTILITY.NAME_TOKENIZE(UPPER('&&nam'), a, b, c, dblink, nextpos);
    IF b IS NULL THEN
        b := a;
        a := USER;
    END IF;
    IF dblink IS NULL THEN
        :result := dig_it(a, b);
        IF :result IS NULL AND a = USER THEN
            :result := dig_it('PUBLIC', b);
        END IF;
        IF :result IS NULL THEN
            :result := 'Item does not exist.';
        END IF;
    ELSE
        :result := 'Cannot resolve a remote object.';
    END IF;
END;
/

PRINT result
UNDEFINE nam
@_END
