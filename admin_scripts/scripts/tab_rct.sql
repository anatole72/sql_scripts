REM
REM  SCRIPT FOR (RE)CREATING TABLES
REM
REM  Running this script will in turn create a script to 
REM  build all the tables owned by the user in the database.  This 
REM  created script can be run by any user with the 'CREATE TABLE' 
REM  system privilege. 
REM
REM  NOTE: The script will NOT include constraints on tables. 
REM

PROMPT
PROMPT SCRIPT TO RECREATE USER TABLES
PROMPT

ACCEPT schema PROMPT "Table owner: "
PROMPT

@_SET
@_HIDE
SET PAGESIZE 0
  
CREATE TABLE temp$t(
    lineno   NUMBER, 
    tb_owner VARCHAR2(30), 
    tb_name  VARCHAR2(30),
    text     VARCHAR2(2000)
)
/
 
DECLARE
    CURSOR tab_cursor IS 
    SELECT   
        table_name,
        pct_free,
        pct_used,
        ini_trans,
        max_trans,
        tablespace_name,
        initial_extent,
        next_extent,
        min_extents,
        max_extents,
        pct_increase,
        freelists,
        freelist_groups
    FROM     
        dba_tables
    WHERE
        owner = UPPER('&schema')
    ORDER BY  
        table_name;

    CURSOR col_cursor (c_tab VARCHAR2) IS 
    SELECT   
        column_name,
        data_type,
        data_length,
        data_precision,
        data_scale,
        nullable
    FROM     
        dba_tab_columns
    WHERE
        table_name = c_tab
        AND owner = UPPER('&schema')
    ORDER BY 
        column_id;

    lv_table_name       dba_tables.table_name%TYPE;
    lv_ini_trans        dba_tables.ini_trans%TYPE;
    lv_max_trans        dba_tables.max_trans%TYPE;
    lv_tablespace_name  dba_tables.tablespace_name%TYPE;
    lv_pct_free         dba_tables.pct_free%TYPE;
    lv_pct_used         dba_tables.pct_used%TYPE;
    lv_initial_extent   dba_tables.initial_extent%TYPE;
    lv_next_extent      dba_tables.next_extent%TYPE;
    lv_min_extents      dba_tables.min_extents%TYPE;
    lv_max_extents      dba_tables.max_extents%TYPE;
    lv_pct_increase     dba_tables.pct_increase%TYPE;
    lv_column_name      dba_tab_columns.column_name%TYPE;
    lv_data_type        dba_tab_columns.data_type%TYPE;
    lv_data_length      dba_tab_columns.data_length%TYPE;
    lv_data_precision   dba_tab_columns.data_precision%TYPE;
    lv_data_scale       dba_tab_columns.data_scale%TYPE;
    lv_nullable         dba_tab_columns.nullable%TYPE;
    lv_freelists	    dba_tables.freelists%TYPE;
    lv_freelist_groups 	dba_tables.freelist_groups%TYPE;
    lv_first_rec        BOOLEAN;
    lv_lineno           NUMBER := 0;
    lv_string           VARCHAR2(2000);
    nul_cnt             NUMBER;
 
    PROCEDURE write_out(
        p_line INTEGER,  
        p_name VARCHAR2,
        p_string VARCHAR2) 
    IS
    BEGIN
        INSERT INTO temp$t (lineno, tb_name, text)
	        VALUES (p_line, p_name, p_string);
    END;
 
BEGIN
    OPEN tab_cursor;
    LOOP
        FETCH tab_cursor INTO     	
            lv_table_name,
            lv_pct_free,
            lv_pct_used,
            lv_ini_trans,
            lv_max_trans,
            lv_tablespace_name,
            lv_initial_extent,
            lv_next_extent,
            lv_min_extents,
            lv_max_extents,
            lv_pct_increase,
            lv_freelists,
            lv_freelist_groups;
        EXIT WHEN tab_cursor%NOTFOUND;

	    lv_lineno := 1;
	    lv_string := 'DROP TABLE '|| LOWER(lv_table_name) || ';';
	    write_out(lv_lineno,  lv_table_name, lv_string);
	    lv_lineno := lv_lineno + 1;
	    lv_first_rec := TRUE;
	    lv_string := 'CREATE TABLE '|| LOWER(lv_table_name) || ' (';
	    write_out(lv_lineno,  lv_table_name, lv_string);
	    lv_lineno := lv_lineno + 1;
        lv_string := NULL;

        OPEN col_cursor(lv_table_name);
        nul_cnt := 0;
        LOOP
	        FETCH col_cursor INTO  
                lv_column_name,
                lv_data_type,
                lv_data_length,
                lv_data_precision,
                lv_data_scale,
                lv_nullable;
	        EXIT WHEN col_cursor%NOTFOUND;

    	    IF (lv_first_rec) THEN
    	        lv_first_rec := FALSE;
    	    ELSE
    	        lv_string :=  ',';
    	    END IF;
    	    lv_string := lv_string || LOWER(lv_column_name) ||
                ' ' || lv_data_type;
    	    IF ((lv_data_type = 'CHAR') OR (lv_data_type = 'VARCHAR2')) THEN
    	        lv_string := lv_string || '(' || lv_data_length || ')';
    	    END IF;
    	    IF (lv_nullable = 'N') THEN
    	        nul_cnt := nul_cnt + 1;
    	        lv_string := lv_string || ' CONSTRAINT CK_' || 
                    lv_table_name || '_' || nul_cnt ||' NOT NULL';
    	    END IF;
            write_out(lv_lineno, lv_table_name, lv_string);
            lv_lineno := lv_lineno + 1;
        END LOOP;
        CLOSE col_cursor;

        lv_string := ')';
        write_out(lv_lineno, lv_table_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := NULL;
        lv_string := 'PCTFREE ' || TO_CHAR(lv_pct_free) ||
                  '   PCTUSED ' || TO_CHAR(lv_pct_used);
        write_out(lv_lineno,  lv_table_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := 'INITRANS ' || TO_CHAR(lv_ini_trans) ||
                    ' MAXTRANS ' || TO_CHAR(lv_max_trans);
        write_out(lv_lineno,  lv_table_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := 'TABLESPACE ' || lv_tablespace_name;
        write_out(lv_lineno,  lv_table_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := 'STORAGE (';
        write_out(lv_lineno,  lv_table_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := 'INITIAL ' || TO_CHAR(lv_initial_extent) ||
		    ' NEXT ' || TO_CHAR(lv_next_extent);
        write_out(lv_lineno,  lv_table_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := 'FREELISTS ' || TO_CHAR(lv_freelists) ||
                    ' FREELIST GROUPS ' || TO_CHAR(lv_max_trans);
        write_out(lv_lineno,  lv_table_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := 'MINEXTENTS '  || TO_CHAR(lv_min_extents) ||
                    ' MAXEXTENTS '  || TO_CHAR(lv_max_extents) ||
                    ' PCTINCREASE ' || TO_CHAR(lv_pct_increase) || ')';
        write_out(lv_lineno,  lv_table_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := '/';
        write_out(lv_lineno,  lv_table_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string:='                                                  ';
        write_out(lv_lineno,  lv_table_name, lv_string);
    END LOOP;
    CLOSE tab_cursor;
END;
/
 
@_BEGIN
SET HEADING OFF
SET PAGESIZE 0
 
SELECT text FROM temp$t ORDER BY tb_name, lineno;
 
@_HIDE
DROP TABLE temp$t;
@_SET
UNDEFINE schema
@_END

