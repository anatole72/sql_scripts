REM
REM  Compile objects in a given schema
REM
REM  Compile package specifications first, then views, then bodies
REM  (this is because a view could reference a package header).
REM
REM  NOTES: The script sometime causes SNAPSHOT TOO OLD message.
REM

@_BEGIN
SET SERVEROUTPUT ON SIZE 10000
SET FEEDBACK ON

PROMPT
PROMPT COMPILE OBJECTS IN A GIVEN SCHEMA
PROMPT

ACCEPT user PROMPT "User schema: "
ACCEPT obj  PROMPT "Object names like (ENTER for all): "
DEFINE schema = "UPPER(LTRIM(RTRIM('&user')))"

PROMPT
PROMPT Compiling invalid objects...
PROMPT

DECLARE

   CURSOR c1 IS
     SELECT object_name, object_type 
     FROM dba_objects
     WHERE owner = &schema 
     AND status = 'INVALID'
     AND object_type = 'PACKAGE'
     AND object_name LIKE NVL(UPPER('&obj'), '%');

   CURSOR c2 IS
      SELECT object_name, object_type 
      FROM dba_objects
      WHERE owner = &schema
      AND status = 'INVALID'
      AND object_type = 'VIEW'
      AND object_name LIKE NVL(UPPER('&obj'), '%');
   --
   -- The select statement here is more complicated because we
   -- have coded it to ignore disabled triggers (even if invalid)
   --
   CURSOR c3 IS
      SELECT DECODE(o.object_type, 'PACKAGE', 1, 2) dummy,
             o.object_name, o.object_type
      FROM dba_objects o
      WHERE o.owner = &schema
      AND o.status = 'INVALID'
      AND o.object_name LIKE NVL(UPPER('&obj'), '%')
      AND o.object_type != 'TRIGGER'
      UNION ALL
      SELECT DECODE(o.object_type, 'PACKAGE', 1, 2) dummy,
             o.object_name, o.object_type
      FROM dba_objects o, dba_triggers t
      WHERE o.owner = &schema
      AND o.status = 'INVALID'
      AND o.object_name LIKE NVL(UPPER('&obj'), '%')
      AND o.object_type = 'TRIGGER'
      AND o.owner = t.owner
      AND o.object_name = t.trigger_name
      AND t.status = 'ENABLED'
      ORDER BY 1;

   --
   -- Local variables
   --
   c                INTEGER;
   rows_processed   INTEGER;
   statement        VARCHAR2(100);
   object_type1     VARCHAR2(30);
   object_type2     VARCHAR2(30);

   success_with_comp_error EXCEPTION;
   PRAGMA EXCEPTION_INIT(success_with_comp_error, -24344);

BEGIN

   -- First compile all invalid packages specifications
   FOR c1rec IN c1 LOOP
     -- For each invalid object compile
      BEGIN
         statement := 'ALTER PACKAGE ' || 
               &schema || '."' || 
               c1rec.object_name ||
               '" COMPILE SPECIFICATION';
         DBMS_OUTPUT.PUT_LINE(statement);
         c := DBMS_SQL.OPEN_CURSOR;
         DBMS_SQL.PARSE(c, statement, DBMS_SQL.NATIVE);
         rows_processed := DBMS_SQL.EXECUTE(c);
         DBMS_SQL.CLOSE_CURSOR(c);
      EXCEPTION
         WHEN success_with_comp_error THEN
            -- Trap and ignore ORA-24344: success with compilation error
            -- This only happens on ORACLE 8
            NULL;
         WHEN OTHERS THEN
            DBMS_SQL.CLOSE_CURSOR(c);
            RAISE;
      END;
   END LOOP;  -- Loop over all invalid packages

   -- Next compile all invalid views
   FOR c2rec IN c2 LOOP
      -- for each invalid object compile
      BEGIN
         statement := 'ALTER VIEW '||
               &schema || '."' ||
               c2rec.object_name ||
               '" COMPILE';
         DBMS_OUTPUT.PUT_LINE(statement);
         c := DBMS_SQL.OPEN_CURSOR;
         DBMS_SQL.PARSE(c, statement, DBMS_SQL.NATIVE);
         rows_processed := DBMS_SQL.EXECUTE(c);
         DBMS_SQL.CLOSE_CURSOR(c);
      EXCEPTION
         WHEN success_with_comp_error THEN
            NULL;
         WHEN OTHERS THEN
            DBMS_SQL.CLOSE_CURSOR(c);
            RAISE;
      END;
   END LOOP;  -- Loop over all invalid views

   -- Last, get all remaining invalid objects, which could be package 
   -- bodies, unpackaged procedures or functions, or triggers
   FOR c3rec IN c3 LOOP
     -- For each invalid object compile
      BEGIN
         object_type1 := c3rec.object_type;
         object_type2 := NULL;

         IF object_type1 = 'PACKAGE BODY' THEN
            object_type1  := 'PACKAGE';
            object_type2 := 'BODY';
         ELSIF object_type1 = 'PACKAGE' THEN
            object_type1  := 'PACKAGE';
            object_type2 := 'SPECIFICATION';
         END IF;

         statement := 'ALTER ' || 
               object_type1 || ' ' || 
               &schema || '."' ||
               c3rec.object_name ||
               '" COMPILE ' || 
               object_type2;

         DBMS_OUTPUT.PUT_LINE(statement);
         c := DBMS_SQL.OPEN_CURSOR;
         DBMS_SQL.PARSE(c, statement, DBMS_SQL.NATIVE);
         rows_processed := DBMS_SQL.EXECUTE(c);
         DBMS_SQL.CLOSE_CURSOR(c);
      EXCEPTION
         WHEN success_with_comp_error THEN
            NULL;
         WHEN OTHERS THEN
            DBMS_SQL.CLOSE_CURSOR(c);
            RAISE;
      END;
   END LOOP;  -- Loop over all remaining invalid objects

END;
/

REM
REM Shows all invalid objects in the schema
REM

@_SET
@_TITLE "INVALID OBJECTS OF &user"

COLUMN object_name FORMAT A30 HEADING "Object Name"
COLUMN object_type FORMAT A14 HEADING "Object Type"
COLUMN last_time FORMAT A18 HEADING "Last Change Time"

SELECT
   object_name,
   object_type,
   TO_CHAR(last_ddl_time, 'DD-MON-YY hh:mi:ss') last_time
FROM
   dba_objects
WHERE
   status = 'INVALID'
   AND owner = &schema
ORDER BY
   object_type, object_name
;

@_END

