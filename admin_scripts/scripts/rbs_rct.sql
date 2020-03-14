REM
REM SCRIPT FOR (RE)CREATING ROLLBACK SEGMENTS
REM
REM This script must be run by a user with select on the DBA views.
REM
REM This script is intended to run with Oracle7 or Oracle8.
REM 
REM Running this script will in turn create a script to re-build 
REM the database rollback segments.  The created script is spooled
REM into the file and can be run by any user with the DBA 
REM role or with the 'CREATE ROLLBACK SEGMENT' system privilege.
REM
REM NOTE:  This script will NOT capture the optimal storage for 
REM        a rollback segment that is offline.
REM 
REM        The rollback segments must be manually brought back online 
REM        after running the generated script.
REM
REM        Only preliminary testing of this script was performed.  Be 
REM        sure to test it completely before relying on it.
REM

@_BEGIN
DEFINE cr='CHR(10)'
@_HIDE

CREATE TABLE temp$rollback (
    lineno NUMBER, 
    rb_name VARCHAR2(30),
    text VARCHAR2(800)
    )
/
 
DECLARE

    CURSOR rb_cursor IS 
    SELECT 
        segment_name,
	tablespace_name,
        DECODE (owner, 'PUBLIC', 'PUBLIC ', NULL),
        segment_id,
        initial_extent,
        next_extent,
        min_extents,
        max_extents, 
        status
    FROM 
        sys.dba_rollback_segs 
    WHERE 
        segment_name <> 'SYSTEM'
    ORDER BY
        segment_name
    ;

    CURSOR rb_optimal (r_no number) IS 
    SELECT 
        usn,
        DECODE(optsize, null, 'NULL', TO_CHAR(optsize))
    FROM 
        sys.v_$rollstat
    WHERE 
        usn = r_no
    ;

    lv_segment_name     sys.dba_rollback_segs.segment_name%TYPE;
    lv_tablespace_name  sys.dba_rollback_segs.tablespace_name%TYPE;
    lv_owner            VARCHAR2(10);
    lv_segment_id       sys.dba_rollback_segs.segment_id%TYPE;
    lv_initial_extent   sys.dba_rollback_segs.initial_extent%TYPE;
    lv_next_extent      sys.dba_rollback_segs.next_extent%TYPE;
    lv_min_extents      sys.dba_rollback_segs.min_extents%TYPE;
    lv_max_extents      sys.dba_rollback_segs.max_extents%TYPE;
    lv_status           sys.dba_rollback_segs.status%TYPE;
    lv_usn              sys.v_$rollstat.usn%TYPE;
    lv_optsize          VARCHAR2(40);
    lv_string           VARCHAR2(800);
    lv_lineno		    NUMBER := 0;
 
    PROCEDURE write_out(p_line INTEGER, p_name VARCHAR2, p_string VARCHAR2) IS
    BEGIN
        INSERT INTO temp$rollback (lineno, rb_name, text) 
            VALUES (p_line, p_name, p_string); 
    END;
 
BEGIN

    OPEN rb_cursor;
    LOOP
        FETCH rb_cursor INTO 
            lv_segment_name,
            lv_tablespace_name,
            lv_owner,
            lv_segment_id,
            lv_initial_extent,
            lv_next_extent,
            lv_min_extents,
            lv_max_extents,
            lv_status;
        EXIT WHEN rb_cursor%NOTFOUND;
        lv_lineno := 1;
        OPEN rb_optimal(lv_segment_id);
        LOOP
            FETCH rb_optimal INTO 
                lv_usn,
                lv_optsize;
            EXIT WHEN rb_optimal%NOTFOUND;           
        END LOOP;
        CLOSE rb_optimal;
        IF lv_status = 'ONLINE' THEN
            lv_string := 'CREATE ' || lv_owner || 'ROLLBACK SEGMENT ' || 
	        lv_segment_name;
            write_out(lv_lineno, lv_segment_name, lv_string);
            lv_lineno := lv_lineno + 1;
            lv_string := 'TABLESPACE ' || lv_tablespace_name;
            write_out(lv_lineno, lv_segment_name, lv_string);
            lv_lineno := lv_lineno + 1;
            lv_string := 'STORAGE ' || '(INITIAL ' || lv_initial_extent || 
                ' NEXT ' || lv_next_extent || &&cr || ' MINEXTENTS ' ||
                lv_min_extents || ' MAXEXTENTS ' || lv_max_extents || &&cr ||
	        ' OPTIMAL ' || lv_optsize || ');';
            write_out(lv_lineno, lv_segment_name, lv_string);
            lv_lineno := lv_lineno + 1;
            lv_string := 'ALTER ROLLBACK SEGMENT ' || lv_segment_name || 
                ' ONLINE;' || &&cr || ' ';
                write_out(lv_lineno, lv_segment_name, lv_string);
        ELSE
            lv_string := 'CREATE ' || lv_owner || 'ROLLBACK SEGMENT ' || 
	        lv_segment_name;
            write_out(lv_lineno, lv_segment_name, lv_string);
            lv_lineno := lv_lineno + 1;
            lv_string := 'TABLESPACE ' || lv_tablespace_name;
            write_out(lv_lineno, lv_segment_name, lv_string);
            lv_lineno := lv_lineno + 1;
            lv_string := 'STORAGE ' || '(INITIAL ' || lv_initial_extent ||
                ' NEXT '|| lv_next_extent || &&cr || ' MINEXTENTS ' || 
                lv_min_extents || ' MAXEXTENTS ' || lv_max_extents || ');';
            write_out(lv_lineno, lv_segment_name, lv_string);
            lv_lineno := lv_lineno + 1;
            lv_string := 'ALTER ROLLBACK SEGMENT ' || lv_segment_name || 
                ' ONLINE;' || &&cr || ' ';
            write_out(lv_lineno, lv_segment_name, lv_string);
        end if;
    END LOOP;
    CLOSE rb_cursor;
END;
/  

@_SET
SET PAGESIZE 0

COLUMN text FORMAT A80 WORD_WRAP
SELECT text
FROM temp$rollback
ORDER BY rb_name, lineno;

@_HIDE 
DROP TABLE temp$rollback;
@_SET
@_END
