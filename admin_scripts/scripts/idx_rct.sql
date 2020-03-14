REM
REM  SCRIPT FOR (RE)CREATING INDEXES
REM
REM  This script must be run by a user with the DBA role.
REM  This script is intended to run with Oracle7.
REM
REM  Running this script will in turn create a script to 
REM  build all the indexes in a user schema.  This created 
REM  script, spooled into output file, can be run by any user 
REM  with the DBA role or with the 'CREATE ANY INDEX' system 
REM  privilege.
REM

PROMPT
PROMPT (RE)CREATING INDEXES
PROMPT
ACCEPT i_own PROMPT "User schema: "
ACCEPT i_nam PROMPT "Index name like (ENTER for all): "

@_BEGIN
@_HIDE 

CREATE TABLE temp$index (
    lineno NUMBER, 
    id_name VARCHAR2(30), 
    text VARCHAR2(2000)
) STORAGE (INITIAL 100K NEXT 100K)
/
 
DECLARE

    CURSOR ind_cursor IS 
    SELECT
        index_name,
        table_owner, 
        table_name,
        uniqueness,
        tablespace_name,
        ini_trans,
        max_trans,
        initial_extent,
        next_extent,
        min_extents,
        max_extents,
        pct_increase,
        pct_free
    FROM     
        dba_indexes
    WHERE
        owner = UPPER('&i_own')
        AND index_name LIKE NVL(UPPER('&i_nam'), '%')
    ORDER BY 
        index_name
    ;

    CURSOR col_cursor (c_ind VARCHAR2, c_tab VARCHAR2) IS
    SELECT column_name
    FROM dba_ind_columns
    WHERE 
        index_name = c_ind
        AND index_owner = UPPER('&i_own')
        AND table_name = c_tab
    ORDER BY column_position;
 
    lv_index_name        dba_indexes.index_name%TYPE;
    lv_table_owner       dba_indexes.table_owner%TYPE;
    lv_table_name        dba_indexes.table_name%TYPE;
    lv_uniqueness        dba_indexes.uniqueness%TYPE;
    lv_tablespace_name   dba_indexes.tablespace_name%TYPE;
    lv_ini_trans         dba_indexes.ini_trans%TYPE;
    lv_max_trans         dba_indexes.max_trans%TYPE;
    lv_initial_extent    dba_indexes.initial_extent%TYPE;
    lv_next_extent       dba_indexes.next_extent%TYPE;
    lv_min_extents       dba_indexes.min_extents%TYPE;
    lv_max_extents       dba_indexes.max_extents%TYPE;
    lv_pct_increase      dba_indexes.pct_increase%TYPE;
    lv_pct_free          dba_indexes.pct_free%TYPE;
    lv_column_name       dba_ind_columns.column_name%TYPE;
    lv_first_rec         BOOLEAN;
    lv_string            VARCHAR2(2000);
    lv_lineno            NUMBER := 0;
 
    PROCEDURE write_out(
        p_line INTEGER, 
        p_name VARCHAR2, 
        p_string VARCHAR2) IS
    BEGIN
        INSERT INTO temp$index (lineno, id_name,text) 
	    VALUES (p_line,p_name,p_string);
    END;
 
BEGIN

    OPEN ind_cursor;
    LOOP
        FETCH ind_cursor INTO     
            lv_index_name,
            lv_table_owner,
            lv_table_name,
            lv_uniqueness,
            lv_tablespace_name,
            lv_ini_trans,
            lv_max_trans,
            lv_initial_extent,
            lv_next_extent,
            lv_min_extents,
            lv_max_extents,
            lv_pct_increase,
            lv_pct_free;
        EXIT WHEN ind_cursor%NOTFOUND;
        lv_lineno := 1;
        lv_first_rec := TRUE;
        IF (lv_uniqueness = 'UNIQUE') THEN
            lv_string:= 'CREATE UNIQUE INDEX ' || LOWER(lv_index_name);
            write_out(lv_lineno, lv_index_name, lv_string);
            lv_lineno := lv_lineno + 1;
        ELSE
            lv_string:= 'CREATE INDEX ' || LOWER(lv_index_name);
	        write_out(lv_lineno,  lv_index_name, lv_string);
	        lv_lineno := lv_lineno + 1;
        END IF;
        OPEN col_cursor(lv_index_name,lv_table_name);
        LOOP
            FETCH col_cursor INTO  lv_column_name;
            EXIT WHEN col_cursor%NOTFOUND;
            IF (lv_first_rec) THEN
                lv_string := '   ON ' || LOWER(lv_table_owner) || '.' || 
                    LOWER(lv_table_name) || ' (';
                lv_first_rec := FALSE;
            ELSE
	            lv_string := lv_string || ', ';
            END IF;
            lv_string := lv_string || LOWER(lv_column_name);
        END LOOP;
        CLOSE col_cursor;
        lv_string := lv_string || ')';
        write_out(lv_lineno,  lv_index_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := NULL;
        lv_string := 'PCTFREE ' || TO_CHAR(lv_pct_free);
        write_out(lv_lineno,  lv_index_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := 'INITRANS ' || TO_CHAR(lv_ini_trans) ||
            ' MAXTRANS ' || TO_CHAR(lv_max_trans);
        write_out(lv_lineno,  lv_index_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := 'TABLESPACE ' || lv_tablespace_name || ' STORAGE (';
        write_out(lv_lineno,  lv_index_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := 'INITIAL ' || TO_CHAR(lv_initial_extent) ||
            ' NEXT ' || TO_CHAR(lv_next_extent);
        write_out(lv_lineno,  lv_index_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := 'MINEXTENTS ' || TO_CHAR(lv_min_extents) ||
            ' MAXEXTENTS ' || TO_CHAR(lv_max_extents) ||
            ' PCTINCREASE ' || TO_CHAR(lv_pct_increase) || ')';
        write_out(lv_lineno,  lv_index_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := '/';
        write_out(lv_lineno,  lv_index_name, lv_string); 
        lv_lineno := lv_lineno + 1;
        lv_lineno := lv_lineno + 1;
        lv_string:='                                                  ';
        write_out(lv_lineno,  lv_index_name, lv_string);
    END LOOP;
    CLOSE ind_cursor;
END;
/

@_SET
SET PAGESIZE 0
COLUMN text FORMAT A80 WORD_WRAP
SELECT text FROM temp$index ORDER BY id_name, lineno;
 
@_HIDE
DROP TABLE temp$index;
UNDEFINE i_own i_nam
@_SET
@_END
