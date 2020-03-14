REM
REM  Script to determine the base tables used in a view 
REM
REM  Does a simple lexical analysis on the view SQL text to extract 
REM  the FROM portion of the SQL such as to attempt to expose all tables 
REM  (objects really) that act as a data provider for that view.
REM

@_BEGIN
SET SERVEROUTPUT ON

PROMPT
PROMPT BASE TABLES USED IN A VIEW
PROMPT

ACCEPT view_own  PROMPT "View owner: "
ACCEPT view_name PROMPT "View name: "
PROMPT

DECLARE

    nam VARCHAR2(50);
    own VARCHAR2(50);
    pos NUMBER;
    txt1 LONG;
    txt2 LONG; 

BEGIN

  -- Gather the initial information an for the long as required
  nam := UPPER('&view_name');
  own := UPPER('&view_own');

  SELECT text
  INTO txt1
  FROM dba_views
  WHERE view_name = nam
  AND owner = own;

  txt1 := UPPER(REPLACE(txt1, CHR(10), ' '));

  -- Process the data
  pos := INSTR(txt1, ' FROM ');
  txt2 := SUBSTR(txt1, pos + 6, INSTR(txt1, ' WHERE ', pos + 6) - 5 - pos);

  -- Output our results to the max of our ability
  DBMS_OUTPUT.PUT_LINE('Base table(s): ' || SUBSTR(txt2, 1, 247));

END; 
/

UNDEFINE view_name view_own
@_END
