REM
REM  SCRIPT FOR RE-CREATING DATABASE TRIGGERS 
REM 
REM  This script can be run by anyone with access to dba_triggers and
REM  is intended to run with Oracle7.
REM              
REM  Running this script will in turn create a script to 
REM  build all the triggers in the database.  
REM

PROMPT
PROMPT SCRIPT FOR RE-CREATING DATABASE TRIGGERS
PROMPT
ACCEPT tr_own PROMPT "Trigger owner like (ENTER for all): "
ACCEPT tr_nam PROMPT "Trigger name like (ENTER for all): "
ACCEPT ta_own PROMPT "Table owner like (ENTER for all): "
ACCEPT ta_nam PROMPT "Table name like (ENTER for all): "
PROMPT

@_SET
@_HIDE
SET PAGESIZE 0
 
CREATE TABLE temp$trig (
    owner VARCHAR2(30),
    trigger_name VARCHAR2(30),
    trigger_type VARCHAR2(16),
    triggering_event VARCHAR2(26),
    table_owner VARCHAR2(30),
    table_name VARCHAR2(30),
    referencing_names VARCHAR2(87),
    when_clause VARCHAR2(2000),
    trigger_body LONG,
    trigger_columns VARCHAR2(400)) 
    STORAGE (INITIAL 100K NEXT 100K)
;

DECLARE
    CURSOR trig_cursor IS 
        SELECT 
            owner,
            trigger_name, 
            trigger_type, 
            triggering_event, 
            'ON ' || table_owner,
            table_name,
            referencing_names,
            'WHEN ' || when_clause,
            trigger_body
        FROM
            dba_triggers 
        WHERE
            owner NOT IN ('SYS', 'SYSTEM')
            AND owner LIKE NVL(UPPER('&&tr_own'), '%')
            AND trigger_name LIKE NVL(UPPER('&&tr_nam'), '%')
            AND table_owner LIKE NVL(UPPER('&&ta_own'), '%')
            AND table_name LIKE NVL(UPPER('&&ta_nam'), '%')
        ORDER BY
            owner,
            trigger_name
        ; 
	
    CURSOR trig_col (owner VARCHAR2, name VARCHAR2) IS 
        SELECT 
            trigger_owner,
            trigger_name,
            column_name
        FROM
            dba_trigger_cols 
        WHERE 
            trigger_owner = owner 
            AND trigger_name = name
        ;

    trig_owner      dba_triggers.owner%TYPE;
    trig_name       dba_triggers.trigger_name%TYPE;
    trig_type       dba_triggers.trigger_type%TYPE;
    trig_event      dba_triggers.triggering_event%TYPE;
    trig_towner     dba_triggers.table_owner%TYPE;
    trig_tname      dba_triggers.table_name%TYPE;
    trig_rnames     dba_triggers.referencing_names%TYPE;
    trig_wclause    dba_triggers.when_clause%TYPE;
    trig_body       dba_triggers.trigger_body%TYPE;   
    trig_col_own    dba_trigger_cols.trigger_owner%TYPE;
    trig_col_nam    dba_trigger_cols.trigger_name%TYPE;
    trig_column     dba_trigger_cols.column_name%TYPE;   
    all_columns     VARCHAR2(400);
    counter         INTEGER := 0;

BEGIN
    OPEN trig_cursor;
    LOOP
        FETCH trig_cursor INTO  
            trig_owner,
            trig_name,
            trig_type,
            trig_event,
            trig_towner,
            trig_tname,
            trig_rnames,
            trig_wclause,
            trig_body
        ;
        EXIT WHEN trig_cursor%NOTFOUND;
        all_columns := '';       
        counter := 0;
        OPEN trig_col(trig_owner, trig_name);
        LOOP
            FETCH trig_col INTO
                trig_col_own,
                trig_col_nam,
                trig_column
            ;
            EXIT WHEN trig_col%NOTFOUND; 
            counter := counter + 1;
            IF counter = 1 THEN
                all_columns := ' OF ' || all_columns || trig_column;
            ELSE
                all_columns := all_columns || ', ' || trig_column;
            END IF;
	    END LOOP;
	    CLOSE trig_col;
	    IF trig_rnames = 'REFERENCING NEW AS NEW OLD AS OLD' then
            trig_rnames := '';
	    END IF;
	    IF trig_wclause = 'WHEN ' THEN
            trig_wclause := '';
	    END IF;
	    INSERT INTO temp$trig VALUES (
            trig_owner,
            trig_name,
            trig_type,
            trig_event,
            trig_towner,
            trig_tname,
            trig_rnames,
            trig_wclause,
            trig_body,
            all_columns
        );
    END LOOP;
    CLOSE trig_cursor;
    COMMIT;
END;
/

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SELECT 
    DECODE(rownum, 1, '', '/' || &&CR) ||
    'CREATE OR REPLACE TRIGGER ' || owner || '.' || trigger_name || &&CR ||
    DECODE(trigger_type, 
        'BEFORE EACH ROW', 'BEFORE ',
        'AFTER EACH ROW', 'AFTER ',
        'BEFORE STATEMENT', 'BEFORE ',
        'AFTER STATEMENT', 'AFTER ',
        trigger_type) || triggering_event || &&CR||
    DECODE(trigger_columns, '', '', trigger_columns || &&CR) ||
    table_owner || '.' || table_name || ' ' || referencing_names || &&CR ||
    DECODE(trigger_type,
        'BEFORE EACH ROW', 'FOR EACH ROW' || &&CR,
        'AFTER EACH ROW', 'FOR EACH ROW' || &&CR,
        '') ||
    when_clause,
    trigger_body
FROM
    temp$trig 
ORDER BY
    owner,
    trigger_name
;

SELECT '/' FROM SYS.DUAL;

@_HIDE
DROP TABLE temp$trig;
UNDEFINE tr_own tr_nam ta_own ta_nam
@_SET
@_END

