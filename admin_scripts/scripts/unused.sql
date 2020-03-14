REM
REM  Determine space allocation within a segment (7.3)
REM

@_BEGIN

PROMPT
PROMPT SEGMENT SPACE ALLOCATION
PROMPT

ACCEPT own PROMPT "Segment owner: "
ACCEPT obj PROMPT "Segment name: "
ACCEPT typ PROMPT "Segment type ((T)able, (I)ndex or (C)luster): "

@_TITLE "SPACE FOR &own..&obj"
SET HEADING OFF
SELECT ' ' FROM sys.dual;

@_SET
SET SERVEROUTPUT ON

DECLARE

   op1 NUMBER;
   op2 NUMBER;
   op3 NUMBER;
   op4 NUMBER;
   op5 NUMBER;
   op6 NUMBER;
   op7 NUMBER;
   obj_type VARCHAR2(10);
   file_name VARCHAR2(255);
   ts_name VARCHAR2(30);

BEGIN
   
   IF UPPER('&typ') = 'T' THEN
      obj_type := 'TABLE';
   ELSIF UPPER('&typ') = 'I' THEN
      obj_type := 'INDEX';
   ELSIF UPPER('&typ') = 'C' THEN
      obj_type := 'CLUSTER';
   ELSE
      dbms_output.put_line('Invalid object type');
      RETURN;
   END IF;

   dbms_space.unused_space(
      UPPER('&own'),
      UPPER('&obj'),
      obj_type, 
      op1, op2, op3, op4, op5, op6, op7
   );

   dbms_output.put_line('Total Blocks              = ' || op1);
   dbms_output.put_line('Total Bytes               = ' || op2);
   dbms_output.put_line('Unused Blocks             = ' || op3);
   dbms_output.put_line('Unused Bytes              = ' || op4);

   SELECT file_name, tablespace_name 
   INTO file_name, ts_name
   FROM dba_data_files
   WHERE file_id = op5;

   dbms_output.put_line('Segment Tablespace        = ' || ts_name);
   dbms_output.put_line('Last Used Extent File ID  = ' || op5);
   dbms_output.put_line('Last Used Extent File     = ' || file_name);
   dbms_output.put_line('Last Used Extent Block ID = ' || op6);
   dbms_output.put_line('Last Used Block           = ' || op7);

END;
/

UNDEFINE obj
UNDEFINE own
UNDEFINE typ

@_END
