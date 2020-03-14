REM 
REM  SQL script to run some RDBMS scripts against a new database.
REM  This script is for Unix, but you can customize it using ADMIN and
REM  PLUS variables.
REM 
REM  Use SQL*Plus with this. It doesn't hurt if some of these have
REM  already been run.
REM 
REM  NOTES:
REM      Before you run this script, make sure that:
REM      - The database is running
REM      - You are pointing to the right database (Check the values
REM        of ORACLE_SID, ORACLE_HOME, and optionally TWO_TASK)
REM      - No one else is using the database
REM

DEFINE admin = "?/rdbms/admin/"
DEFINE plus  = "?/sqlplus/admin/"

@_BEGIN
SET PAGESIZE 0

PROMPT
PROMPT THIS SCRIPT RUNS RDBMS SCRIPTS NEEDED AFTER DATABASE CREATION
PROMPT
ACCEPT sys_pwd PROMPT 'Enter SYS password: '
ACCEPT system_pwd PROMPT 'Enter SYSTEM password: '

PROMPT
REM Ensure you can connect to both accounts using the passwords given

REM WHENEVER SQLERROR EXIT SQL.SQLCODE;
CONNECT system/&system_pwd
CONNECT sys/&sys_pwd

PROMPT If either of the previous connects failed, please exit this script
PROMPT (using CONTROL-C or BREAK) and restart, otherwise press [RETURN]
ACCEPT answer

WHENEVER OSERROR EXIT FAILURE;

SET HEADING OFF
SET FEEDBACK OFF
SELECT '*** PREPDB started at '||
    TO_CHAR(SYSDATE, 'DD-MON-YY HH:MI:SS') || ' ***' 
FROM 
    SYS.DUAL;
SET HEADING ON
SET FEEDBACK ON

REM Following needed as drop object occurs without object existing
WHENEVER SQLERROR CONTINUE;

REM
REM Create Oracle7 data dictionary views
REM
PROMPT
PROMPT Running catalog.sql ...
@&admin.catalog.sql

REM
REM Create V6 data dictionary views not covered by catalog.sql
REM
PROMPT Running catalog6.sql ...
@&admin.catalog6.sql

REM
REM Create views used by Oracle7 Export/Import
REM
PROMPT Running catexp.sql ...
@&admin.catexp.sql

REM
REM Create V6-style Export views in an Oracle7 database
REM
PROMPT Running catexp6.sql ...
@&admin.catexp6.sql

REM
REM Run scripts to configure PL/SQL
REM
PROMPT Running catproc.sql ...
@&admin.catproc.sql

REM
REM Create Parallel-Server specific views.
REM Run this script even if you do not use Parallel Server.
REM
PROMPT Running catparr.sql ...
@&admin.catparr.sql

REM Following not needed since catproc.sql runs
REM
REM Create data dictionary views for stored procedures and triggers.
REM @&admin.catprc.sql
REM Create data dictionary views for snapshots.
REM @&admin.catsnap.sql
REM Create package for dbms "pipes" and grant it to public
REM @&admin.dbmspipe.sql
REM Create packages for dbms locks
REM @&admin.dbmslock.sql
REM Create the dbmsotpt package
REM @&admin.dbmsotpt.sql

REM
REM Create the dbms_shared_pool package and grant it to public
REM
PROMPT Running dbmspool.sql ...
@&admin.dbmspool.sql
PROMPT Running prvtpool.sql ...
@&admin.prvtpool.sql

REM
REM Grant public access to views used by character-mode SQL*DBA
REM
PROMPT Running utlmontr.sql ...
@&admin.utlmontr.sql

REM
REM Create packages/grants/synonyms for distributed applications support
REM
PROMPT Setting up package for runtime DDL ...
@&admin.dbmssql.sql
@&admin.prvtsql.plb

REM
REM Connect to SYSTEM 
REM
CONNECT system/&system_pwd

REM
REM Create private synonyms for DBA-only data dictionary views.
REM
PROMPT Running catdbsyn.sql ...
@&admin.catdbsyn.sql

REM
REM Create product_profile and user_profile tables.
REM
PROMPT Running pupbld.sql ...
@&plus.pupbld.sql

REM 
REM End of prep_db.sql
REM

SET HEADING OFF
SET FEEDBACK OFF
SELECT '*** PREPDB completed at ' ||
    TO_CHAR(SYSDATE, 'DD-MON-YY HH:MI:SS') || ' ***' 
FROM SYS.DUAL;
SET HEADING ON
SET FEEDBACK ON
PROMPT
UNDEFINE admin plus answer
@_END
