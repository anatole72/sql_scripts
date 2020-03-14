REM 
REM  The following script will generate a view DBA_USER_PRIVS which
REM  may be queried to obtain information about which privileges
REM  are available to a given user, or which users enjoy a
REM  particular privilege.
REM
REM  The script should be run as SYS.
REM

CREATE OR REPLACE VIEW dba_user_privs (username, rolename, privilege) AS
SELECT 
    DECODE(sa1.grantee#, 1, 'PUBLIC', u1.name), 
    SUBSTR(u2.name, 1, 20),
    SUBSTR(spm.name, 1, 27)
FROM 
    sys.sysauth$ sa1, 
    sys.sysauth$ sa2, 
    sys.user$ u1,
    sys.user$ u2, 
    sys.system_privilege_map spm
WHERE 
    sa1.grantee# = u1.user#
    AND sa1.privilege# = u2.user#
    AND u2.user# = sa2.grantee#
    AND sa2.privilege# = spm.privilege
UNION
SELECT 
    u.name, 
    NULL, 
    SUBSTR(spm.name, 1, 27)
FROM 
    sys.system_privilege_map spm, 
    sys.sysauth$ sa, 
    sys.user$ u
WHERE 
    sa.grantee# = u.user#
    AND sa.privilege# = spm.privilege
/

