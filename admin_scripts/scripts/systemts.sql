REM
REM  Having your system tablespace used for purposes other than storing the 
REM  Oracle dictionary can not only cause poor performance, but also cause 
REM  the database to crash if a dictionary table needs to be extended and it has 
REM  insufficient free disk space.              
REM     
REM  Author:   Mark Gurry
REM

@_BEGIN
SET HEADING OFF

COLUMN owner        FORMAT A25
COLUMN segment_name FORMAT A30
COLUMN segment_type FORMAT A20

SELECT 
    'The following is a list of all objects that are owned by users other than SYS ' nl,
    'and SYSTEM but are stored in the SYSTEM tablespace...' nl
FROM 
    DUAL         
WHERE 
    0 < ( 
        SELECT COUNT(*) 
        FROM dba_segments 
        WHERE owner NOT IN ('SYS', 'SYSTEM')
        AND tablespace_name = 'SYSTEM'  
        )
/

BREAK ON owner SKIP 1
SET HEADING ON
SELECT owner, segment_name, segment_type
FROM dba_segments 
WHERE owner NOT IN ('SYS', 'SYSTEM')
AND tablespace_name = 'SYSTEM'  
ORDER BY owner, segment_name
/

SET HEADING OFF
SELECT 
    'You have modified your SYSTEM tablespace PCTINCREASE to ' || pct_increase || '%.' nl,
    'This is different to Oracles recommended setting of 50%.' nl,
    'Make sure that you will not have any problems as a result of this... ' nl
FROM dba_tablespaces
WHERE pct_increase != 50
AND tablespace_name = 'SYSTEM'
/

SELECT 
    'The following users have the SYSTEM tablespace as their default tablespace. ' nl,
    'This is bad practice because it can often cause the SYSTEM tablespace to fill ' nl,
    'and Oracle to grind to a halt... ' nl
FROM dual         
WHERE 0 < ( 
    SELECT COUNT(*) 
    FROM dba_users     
    WHERE username NOT IN ('SYS', 'SYSTEM')
    AND default_tablespace = 'SYSTEM'  
)
/

SET HEADING ON
SELECT username
FROM dba_users     
WHERE username NOT IN ('SYS', 'SYSTEM')
AND default_tablespace = 'SYSTEM' 
ORDER BY username
/
 
SET HEADING OFF
SELECT 
    'The following users have the SYSTEM tablespace as their temporary tablespace. ' nl,
    'This is bad practice because it can often cause the SYSTEM tablespace to fill ' nl,
    'and Oracle to grind to a halt... ' nl
FROM dual         
WHERE 0 < ( 
    SELECT COUNT(*) 
    FROM dba_users     
    WHERE username NOT IN ('SYS', 'SYSTEM')
    AND temporary_tablespace = 'SYSTEM'  
)
/

SET HEADING ON
SELECT username
FROM dba_users     
WHERE username NOT IN ('SYS', 'SYSTEM')
AND temporary_tablespace = 'SYSTEM' 
ORDER BY username
/
 
@_END
 
