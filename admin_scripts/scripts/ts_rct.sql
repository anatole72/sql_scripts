REM 
REM  SCRIPT FOR CREATING TABLESPACES
REM
REM  Running this script will in turn create a script to build all the
REM  tablespaces in the database.  This created script can be run by 
REM  any user with the DBA role or with the 'CREATE TABLESPACE' 
REM  system privilege.
REM
 
@_SET
@_HIDE
SET PAGESIZE 0
 
CREATE TABLE temp$ts (lineno NUMBER, ts_name VARCHAR2(30),
    text VARCHAR2(800))
/ 

DECLARE
    CURSOR ts_cursor IS 
        SELECT   
            tablespace_name,
            initial_extent,
            next_extent,
            min_extents,
            max_extents,
            pct_increase,
            status
        FROM    
            sys.dba_tablespaces
        WHERE 
            tablespace_name != 'SYSTEM'
            AND status != 'INVALID'
        ORDER BY 
            tablespace_name;

    CURSOR df_cursor (c_ts VARCHAR2) IS 
        SELECT   
            file_name,
            bytes
        FROM     
            sys.dba_data_files
        WHERE 
            tablespace_name = c_ts
            AND tablespace_name != 'SYSTEM'
        ORDER BY 
            file_name;

    lv_tablespace_name   sys.dba_tablespaces.tablespace_name%TYPE;
    lv_initial_extent    sys.dba_tablespaces.initial_extent%TYPE;
    lv_next_extent       sys.dba_tablespaces.next_extent%TYPE;
    lv_min_extents       sys.dba_tablespaces.min_extents%TYPE;
    lv_max_extents       sys.dba_tablespaces.max_extents%TYPE;
    lv_pct_increase      sys.dba_tablespaces.pct_increase%TYPE;
    lv_status            sys.dba_tablespaces.status%TYPE;
    lv_file_name         sys.dba_data_files.file_name%TYPE;
    lv_bytes             sys.dba_data_files.bytes%TYPE;
    lv_first_rec         BOOLEAN;
    lv_string            VARCHAR2(800);
    lv_lineno            NUMBER := 0;
 
    PROCEDURE write_out(p_line INTEGER, p_name VARCHAR2, 
        p_string VARCHAR2) IS
    BEGIN
        INSERT INTO temp$ts (lineno, ts_name, text) VALUES 
            (p_line, p_name, p_string);
    END;
 
BEGIN
    OPEN ts_cursor;
    LOOP
        FETCH ts_cursor INTO 
            lv_tablespace_name,
            lv_initial_extent,
            lv_next_extent,
            lv_min_extents,
            lv_max_extents,
            lv_pct_increase,
            lv_status
        ;
        EXIT WHEN ts_cursor%NOTFOUND;
        lv_lineno := 1;
        lv_string := ('CREATE TABLESPACE ' || LOWER(lv_tablespace_name));
        lv_first_rec := TRUE;
        write_out(lv_lineno, lv_tablespace_name, lv_string);
        OPEN df_cursor(lv_tablespace_name);
        LOOP
            FETCH df_cursor INTO lv_file_name, lv_bytes;
            EXIT WHEN df_cursor%NOTFOUND;
            IF (lv_first_rec) THEN
                lv_first_rec := FALSE;
                lv_string := 'DATAFILE ';
            ELSE
                lv_string := lv_string || ',';
            END IF;
            lv_string := lv_string || '''' || lv_file_name || '''' ||
                ' SIZE ' || TO_CHAR(lv_bytes) || ' REUSE';
        END LOOP;
        CLOSE df_cursor;
        lv_lineno := lv_lineno + 1;
        write_out(lv_lineno, lv_tablespace_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := (' DEFAULT STORAGE (INITIAL ' ||
            TO_CHAR(lv_initial_extent) ||
            ' NEXT ' || lv_next_extent);
        write_out(lv_lineno, lv_tablespace_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := (' MINEXTENTS ' || lv_min_extents ||
            ' MAXEXTENTS ' || lv_max_extents);
        write_out(lv_lineno, lv_tablespace_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := (' PCTINCREASE ' ||
            lv_pct_increase || ')');
        write_out(lv_lineno, lv_tablespace_name, lv_string);
        lv_string := ('   ' || lv_status);
        write_out(lv_lineno, lv_tablespace_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := '/';
        write_out(lv_lineno, lv_tablespace_name, lv_string);
        lv_lineno := lv_lineno + 1;
        lv_string := '                                                  ';
        write_out(lv_lineno, lv_tablespace_name, lv_string);
    END LOOP;
    CLOSE ts_cursor;
END;
/
@_BEGIN
SET PAGESIZE 0

SELECT text FROM temp$ts ORDER BY ts_name, lineno;
 
@_HIDE
DROP TABLE temp$ts;
@_SET
@_END

