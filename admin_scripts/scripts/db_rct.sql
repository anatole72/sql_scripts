REM
REM  SCRIPT FOR (RE)CREATING DB
REM
REM  Notes:   1. This script must be run by a user with the DBA role.
REM           2. This script is intended to run with Oracle 7.3
REM           3. Running this script will in turn create a script to 
REM           rebuild the database.  
REM
REM  M. Ault 3/29/96 TRECOM, REVELNET
REM  S. Stetsenko 01/14/97 (CHARACTER SET)
REM

@_BEGIN
@_HIDE

CREATE TABLE temp$db
     (lineno NUMBER,  text VARCHAR2(255))
/

DECLARE
    CURSOR dbf_cursor IS 
	    SELECT file_name, bytes	
	    FROM dba_data_files
	    WHERE tablespace_name = 'SYSTEM';

    CURSOR grp_cursor IS
 	    SELECT group# FROM v$log; 

    CURSOR mem_cursor (grp_num number) IS
	    SELECT a.member, b.bytes 
        FROM v$logfile a, v$log b
	    WHERE a.group# = grp_num
	    AND a.group# = b.group#
	    ORDER BY member;

    grp_member  v$logfile.member%TYPE;
    bytes	    v$log.bytes%TYPE;
    db_name	    VARCHAR2(8);
    db_string   VARCHAR2(255);
    db_lineno   NUMBER := 0;
    thrd	    NUMBER;
    grp		    NUMBER;
    filename	dba_data_files.file_name%TYPE;
    sz		    NUMBER;
    begin_count	NUMBER;
    max_group	NUMBER;

    PROCEDURE write_out(p_line INTEGER, p_string VARCHAR2) IS
    BEGIN
        INSERT INTO temp$db (lineno,text) VALUES (db_lineno,db_string);
    END;

BEGIN
    SELECT MAX(group#) INTO max_group FROM v$log;
    db_lineno := db_lineno + 1;
    SELECT 'CREATE DATABASE ' || name INTO db_string FROM v$database;
    write_out(db_lineno, db_string);
    db_lineno := db_lineno + 1;
    SELECT 'CONTROLFILE REUSE' INTO db_string FROM dual;
    write_out(db_lineno, db_string);
    db_lineno := db_lineno + 1;
    SELECT 'LOGFILE ' INTO db_string FROM dual;
    write_out(db_lineno, db_string);
    COMMIT;

    IF grp_cursor%ISOPEN THEN
	    CLOSE grp_cursor;
	    OPEN grp_cursor;
    ELSE
	    OPEN grp_cursor;
    END IF;

    LOOP
  	    FETCH grp_cursor INTO grp;
	    EXIT WHEN grp_cursor%NOTFOUND;
	    db_lineno := db_lineno + 1;
	    db_string := ' GROUP ' || grp || ' (';
	    write_out(db_lineno, db_string);

	    IF mem_cursor%ISOPEN THEN
	        CLOSE mem_cursor;
            OPEN mem_cursor(grp);
	    ELSE
            OPEN mem_cursor(grp);
	    END IF;

	    db_lineno := db_lineno + 1;
	    begin_count := db_lineno;

	    LOOP
            FETCH mem_cursor INTO grp_member, bytes;
            EXIT WHEN mem_cursor%NOTFOUND;
            IF begin_count = db_lineno THEN
                db_string := CHR(39) || grp_member || CHR(39);
                write_out(db_lineno, db_string);
                db_lineno := db_lineno + 1;
            ELSE
                db_string := ',' || CHR(39) || grp_member || CHR(39);
                write_out(db_lineno, db_string);
                db_lineno := db_lineno + 1;
            END IF;
        END LOOP;

	    db_lineno := db_lineno + 1;
	    IF grp = max_group THEN
            db_string := ' ) SIZE ' || bytes;
            write_out(db_lineno, db_string);
	    ELSE
            db_string :=' ) SIZE ' || bytes || ',';
            write_out(db_lineno, db_string);
	    END IF;
    END LOOP;

    IF dbf_cursor%ISOPEN THEN
        CLOSE dbf_cursor;
	    OPEN dbf_cursor;
    ELSE
	    OPEN dbf_cursor;
    END IF;

    begin_count := db_lineno;
    LOOP
        FETCH dbf_cursor INTO filename, sz;
        EXIT WHEN dbf_cursor%NOTFOUND;
        IF begin_count = db_lineno THEN
            db_string := 'DATAFILE ' || CHR(39) || filename || CHR(39) 
                || ' SIZE ' || sz || ' REUSE';
        ELSE
            db_string := ',' || CHR(39) || filename || CHR(39) 
                || ' SIZE ' || sz || ' REUSE';
        END IF;
        db_lineno := db_lineno + 1;
        write_out(db_lineno, db_string);
    END LOOP;
    COMMIT;

    SELECT DECODE(value, 'TRUE', 'ARCHIVELOG', 'FALSE', 'NOARCHIVELOG')
    INTO db_string 
    FROM v$parameter 
    WHERE name = 'log_archive_start';

    db_lineno := db_lineno + 1;
    write_out(db_lineno, db_string);

    SELECT 'CHARACTER SET ' || value 
    INTO db_string
    FROM v$nls_parameters
    WHERE parameter = 'NLS_CHARACTERSET';

    db_lineno := db_lineno + 1;
    write_out(db_lineno, db_string);

    SELECT ';' INTO db_string FROM dual;
    db_lineno := db_lineno + 1;
    write_out(db_lineno, db_string);

    CLOSE dbf_cursor;
    CLOSE mem_cursor;
    CLOSE grp_cursor;
    COMMIT;
END;
/

@_BEGIN
COLUMN text FORMAT A80 WORD_WRAP
SET PAGESIZE 0

SELECT text FROM temp$db ORDER BY lineno;

@_HIDE
DROP TABLE temp$db;
@_SET
@_END

