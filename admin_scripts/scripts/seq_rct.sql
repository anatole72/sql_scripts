REM
REM  SCRIPT FOR RE-CREATING DATABASE SEQUENCES
REM
REM  Running this script will in turn create a script to 
REM  build all the sequences in the database.  
REM 
REM  This script will start the sequence (start with value) 
REM  at the last value of the sequence at the time the 
REM  script is run (LAST_NUMBER).
REM

PROMPT
PROMPT GENERATE SCRIPT TO RECREATE SEQUENCES
PROMPT
ACCEPT own PROMPT "Sequence owner like (ENTER for all): "
ACCEPT nam PROMPT "Sequence name like (ENTER for all): "
 
@_BEGIN
DEFINE LF = 'CHR(10)'
@_HIDE 
 
CREATE TABLE temp$sequences (
    grantor_owner VARCHAR2(30),
    text VARCHAR2(255)
    )
/ 

DECLARE
    CURSOR seq_cursor IS 
    SELECT   
        sequence_owner,
        sequence_name, 
        min_value, 
        max_value, 
        increment_by,
        DECODE(cycle_flag, 'Y', 'CYCLE', 'NOCYCLE'),
        DECODE(order_flag, 'Y', 'ORDER', 'NOORDER'),
        DECODE(TO_CHAR(cache_size),
            '0', 'NOCACHE',
            'CACHE ' || TO_CHAR(cache_size)
        ),
        last_number
    FROM 
        dba_sequences 
    WHERE 
        sequence_owner LIKE NVL(UPPER('&&own'), '%')
        AND sequence_name LIKE NVL(UPPER('&&nam'), '%')
    ORDER BY 
        sequence_owner, sequence_name
    ; 

    seq_owner	dba_sequences.sequence_owner%TYPE;
    seq_name	dba_sequences.sequence_name%TYPE;
    seq_min	    dba_sequences.min_value%TYPE;
    seq_max	    dba_sequences.max_value%TYPE;
    seq_inc	    dba_sequences.increment_by%TYPE;
    seq_order	VARCHAR2(7);
    seq_cycle	VARCHAR2(7);
    seq_cache	VARCHAR2(15);
    seq_lnum	dba_sequences.last_number%TYPE;   
    seq_string 	VARCHAR2(255);

    PROCEDURE write_out(p_string VARCHAR2) is
    BEGIN
        INSERT INTO temp$sequences (grantor_owner, text) 
            VALUES (seq_owner, p_string);
    END;
 
BEGIN
    OPEN seq_cursor;
    LOOP
        FETCH seq_cursor INTO     
            seq_owner,
            seq_name,
            seq_min,
            seq_max,
            seq_inc,
            seq_order,
            seq_cycle,
            seq_cache,
            seq_lnum;
        EXIT WHEN seq_cursor%NOTFOUND;
	    seq_string := ('CREATE SEQUENCE ' || seq_owner || '.' || seq_name || &&LF ||
                       'INCREMENT BY ' || seq_inc || &&LF ||
                       'START WITH ' || seq_lnum || &&LF ||
                       'MAXVALUE ' || seq_max || &&LF ||
                       'MINVALUE ' || seq_min || &&LF ||
                       seq_cycle || &&LF || 
                       seq_cache || &&LF ||
                       seq_order || ';' || &&LF || ' ' || &&LF);   
        write_out(seq_string);
    END LOOP;
    CLOSE seq_cursor;
END;
/

@_SET
SET PAGESIZE 0

COLUMN text FORMAT A79 WORD_WRAP
COLUMN downer NOPRINT 
BREAK ON downer SKIP 1
SELECT 
    grantor_owner downer, text
FROM  
    temp$sequences 
ORDER BY 
    downer 
/

@_HIDE 
DROP TABLE temp$sequences;
UNDEFINE own nam
@_SET
@_END
