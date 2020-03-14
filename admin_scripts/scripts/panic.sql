REM
REM  Database emergency script
REM 

@_BEGIN

SET PAGESIZE 0
SET FEEDBACK OFF

PROMPT REM
PROMPT REM   EMERGENCY SCRIPT
PROMPT REM

PROMPT 
PROMPT REM
PROMPT REM   Create All Tablespaces
PROMPT REM
PROMPT 

SELECT 
    'CREATE TABLESPACE ' || t.tablespace_name || CHR(10) || 
    'DATAFILE ''' || f.file_name ||
    ''' SIZE ' || TO_CHAR(f.bytes / 1048576) || 'M' || CHR(10) ||
    'DEFAULT STORAGE (INITIAL ' || TO_CHAR(t.initial_extent) ||
    ' NEXT ' || TO_CHAR(t.next_extent) || ' MINEXTENTS ' || 
    TO_CHAR(t.min_extents) || CHR(10) ||
    '         MAXEXTENTS ' || TO_CHAR(t.max_extents) || ' PCTINCREASE ' || 
    TO_CHAR(t.pct_increase) || ') ONLINE;'
FROM 
    sys.dba_data_files f,
    sys.dba_tablespaces  t
WHERE 
    t.tablespace_name  = f.tablespace_name
AND t.tablespace_name != 'SYSTEM'
AND f.file_id = ( 
    SELECT MIN(file_id)
    FROM   sys.dba_data_files
    WHERE  tablespace_name = t.tablespace_name 
)
/
PROMPT 
PROMPT REM
PROMPT REM   Create All Tablespace Datafile Extents
PROMPT REM
PROMPT 

SELECT 
    'ALTER TABLESPACE ' || t.tablespace_name || CHR(10) || 
    'ADD DATAFILE ''' || f.file_name || ''' SIZE ' || 
    TO_CHAR(f.bytes / 1048576) || 'M;'
FROM
    sys.dba_data_files f,
    sys.dba_tablespaces t
WHERE
    t.tablespace_name = f.tablespace_name
AND f.file_id != ( 
    SELECT MIN(file_id)
    FROM   sys.dba_data_files
    WHERE  tablespace_name = t.tablespace_name 
)
/

PROMPT 
PROMPT REM
PROMPT REM   Create System Roles
PROMPT REM
PROMPT 

SELECT 
    'CREATE ROLE '|| role || DECODE(password_required, 
        'N',' NOT IDENTIFIED;',
        ' IDENTIFIED EXTERNALLY;')
FROM   
    sys.dba_roles
/

PROMPT 
PROMPT REM
PROMPT REM   Create System Profiles 
PROMPT REM
PROMPT 

SELECT DISTINCT 
    'CREATE PROFILE ' || profile || ' LIMIT ' || ';'
FROM    
    sys.dba_profiles
/

SELECT  
    'ALTER ROLE ' || profile || ' LIMIT ' ||
    resource_name || ' ' || LIMIT || ';'
FROM
    sys.dba_profiles
WHERE   
    limit   != 'DEFAULT'
    AND (profile != 'DEFAULT' OR limit   != 'UNLIMITED' )
/

PROMPT 
PROMPT REM
PROMPT REM   Create ALL User Connections 
PROMPT REM
PROMPT 

SELECT 
    'CREATE USER ' || username ||
    ' IDENTIFIED BY XXXXX ' || CHR(10) ||
    ' DEFAULT TABLESPACE ' || default_tablespace ||
    ' TEMPORARY TABLESPACE '|| temporary_tablespace || CHR(10) ||
    ' QUOTA UNLIMITED ON ' || default_tablespace || ' ' ||
    ' QUOTA UNLIMITED ON ' || temporary_tablespace || ';'
FROM   
    sys.dba_users
WHERE  
    username NOT IN ('SYSTEM', 'SYS', '_NEXT_USER', 'PUBLIC')
/

PROMPT 
PROMPT REM
PROMPT REM   Reset User Passwords
PROMPT REM
PROMPT 

SELECT 
    'ALTER USER ' || username || ' IDENTIFIED BY VALUES ''' ||
    password || ''';'
FROM   
    sys.dba_users
WHERE  
    username NOT IN ('SYSTEM', 'SYS', '_NEXT_USER', 'PUBLIC')
    AND password != 'EXTERNAL'
/

PROMPT 
PROMPT REM
PROMPT REM   Create Tablespace Quotas     
PROMPT REM
PROMPT 

SELECT 
    'ALTER USER ' || username || ' QUOTA ' ||
    DECODE(max_bytes, -1, 'UNLIMITED', TO_CHAR(max_bytes / 1024) ||' K') ||
    ' ON TABLESPACE ' || tablespace_name || ';'
FROM
    sys.dba_ts_quotas
/

PROMPT 
PROMPT REM
PROMPT REM   Grant System Privileges 
PROMPT REM
PROMPT 

SELECT 
    'GRANT ' || s.name || ' TO ' || u.username || ';'
FROM   
    system_privilege_map s,
    sys.sysauth$ p,
    sys.dba_users u
WHERE  
    u.user_id = p.grantee#
    AND p.privilege# = s.privilege
    AND p.privilege# < 0
/

PROMPT 
PROMPT REM
PROMPT REM   Grant System Roles  
PROMPT REM
PROMPT 

SELECT 
    'GRANT ' || x.name || ' TO ' || u.username || ';'
FROM   
    sys.user$ x,
    sys.dba_users u
WHERE  
    x.user# IN ( 
        SELECT  privilege# 
        FROM    sys.sysauth$ 
        CONNECT BY grantee# = PRIOR privilege# AND privilege# > 0
        START WITH grantee# IN (1, u.user_id) AND privilege# > 0 
    )  
/

PROMPT 
PROMPT REM
PROMPT REM   Create All PUBLIC Synonyms
PROMPT REM
PROMPT 

SELECT 
    'CREATE PUBLIC SYNONYM ' || synonym_name || ' FOR ' ||
    DECODE(table_owner, '', '', table_owner || '.') || table_name || 
    DECODE(db_link, '', '', '@' || db_link) || ';'
FROM   
    sys.dba_synonyms
WHERE  
    owner = 'PUBLIC'
    AND table_owner != 'SYS'
/

PROMPT 
PROMPT REM
PROMPT REM   Create ALL Public Database Links
PROMPT REM
PROMPT 

SELECT 
    'CREATE PUBLIC DATABASE LINK ' || db_link || CHR(10) ||
    'CONNECT TO ' || username || ' IDENTIFIED BY XXXXXX USING ''' ||
    host || ''';'
FROM   
    sys.dba_db_links
WHERE  
    owner = 'PUBLIC'
/

PROMPT 
PROMPT REM
PROMPT REM   Create Rollback Segments
PROMPT REM
PROMPT 

SELECT 
    'CREATE ROLLBACK SEGMENT ' || segment_name || 
    ' TABLESPACE ' || tablespace_name || CHR(10) ||
    'STORAGE (INITIAL ' || TO_CHAR(initial_extent) ||
    ' NEXT ' || TO_CHAR(next_extent) || ' MINEXTENTS ' ||
    TO_CHAR(min_extents) || CHR(10) ||
    ' MAXEXTENTS ' || TO_CHAR(max_extents) || ') ' ||
    status || ';'
FROM   
    sys.dba_rollback_segs
WHERE  
    segment_name != 'SYSTEM'
/

@_END	
