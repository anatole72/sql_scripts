PROMPT
PROMPT CHANGE DATABASE CHARACTER SET
PROMPT
PROMPT THIS IS A VERY DANGEROUS SCRIPT BECAUSE YOU MAY ACCIDENTALLY LOST
PROMPT YOUR DATABASE.
PROMPT
PROMPT To continue, press RETURN...
ACCEPT ans CHAR

SET ECHO OFF
SET VERIFY OFF
 
REM The data dictionary table that records the database
REM character set is sys.props$
REM
REM SQL> describe sys.props$
REM  Name                            Null?    Type
REM  ------------------------------- -------- ----
REM  NAME                            NOT NULL VARCHAR2(30)
REM  VALUE$                                   VARCHAR2(2000)
REM  COMMENT$                                 VARCHAR2(2000)
 
REM For example:
REM
REM SQL> column c1 format a30
REM SQL> select name c1, value$ c1 from sys.props$;
 
REM C1                             C1
REM ------------------------------ ------------------------------
REM DICT.BASE                      2
REM NLS_LANGUAGE                   AMERICAN
REM NLS_TERRITORY                  AMERICA
REM NLS_CURRENCY                   $
REM NLS_ISO_CURRENCY               AMERICA
REM NLS_NUMERIC_CHARACTERS         .,
REM NLS_DATE_FORMAT                DD-MON-YY
REM NLS_DATE_LANGUAGE              AMERICAN
REM NLS_CHARACTERSET               WE8DEC
REM NLS_SORT                       BINARY
REM GLOBAL_DB_NAME                 NLSV7.WORLD
 
REM NLS_CHARACTERSET can be changed by updating its value, for example:
 
REM update sys.props$
REM set    value$ = 'WE8ISO8859P1'
REM Where  name = 'NLS_CHARACTERSET';
 
REM The database has to be shutdown and restarted before the change
REM becomes efective.
 
REM It is very important to specify the character set name correctly.
REM IMPORTANT NOTE
REM =============
REM If NLS_CHARACTERSET is updated to an invalid value, it will not then
REM be possible to restart the database once it has been shutdown.
REM To recover, it will be necessary to re-create the database, since it
REM cannot be restarted to correct the invalid NLS_CHARACTERSET entry.
 
REM The character set name should be in uppercase.
REM The new value is not effective until the database has been shutdown and
REM restarted.
REM
REM A suggested procedure is as follows, and can be done by running this
REM script from SQL*Plus when logged into the SYSTEM account.
REM

ACCEPT chs PROMPT "Desired database character set: "
PROMPT
PROMPT First check that the character set name is valid.
PROMPT
 
SET ECHO ON
SELECT CONVERT('a', '&chs', 'US7ASCII') FROM DUAL;
SET ECHO OFF

PROMPT
PROMPT If this select statement returns error ORA-01482, then the
PROMPT specified character set name is not valid for this installation.
PROMPT Abort the procedure now with CTRL/C.
PROMPT 
PROMPT To continue, press RETURN...
ACCEPT ans CHAR
 
PROMPT Check the current value of database character set.
 
COLUMN c1 FORMAT A30
SELECT name c1, value$ c1
FROM sys.props$
WHERE name = 'NLS_CHARACTERSET';
 
PROMPT To continue, press RETURN...
ACCEPT ans CHAR
 
PROMPT Update to new character set.
 
UPDATE sys.props$
SET    value$ = UPPER('&chs')
WHERE  name = 'NLS_CHARACTERSET';
 
SET ECHO OFF
PROMPT To continue, press RETURN...
ACCEPT ans CHAR
 
PROMPT Check the new value of database character set.
 
SELECT name c1, value$ c1
FROM sys.props$
WHERE name = 'NLS_CHARACTERSET';

PROMPT If the value is updated as required, press RETURN to continue and
PROMPT then manually type COMMIT; to commit the change. Then shutdown and
PROMPT restart the database.
PROMPT
PROMPT If the value is not updated as required, press RETURN to continue and
PROMPT than manually type ROLLBACK; to prevent the change.
PROMPT
PROMPT To continue, press RETURN...
ACCEPT ans CHAR

UNDEFINE ans chs
