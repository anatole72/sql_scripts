REM
REM  Report how much space each user has.
REM

PROMPT
PROMPT Q U O T A   U S A G E
PROMPT
ACCEPT usr PROMPT "User name like (ENTER for all): "
ACCEPT ts  PROMPT "Tablespace name like (ENTER for all): "

@_BEGIN
@_TITLE 'QUOTA USAGE'

BREAK ON tablespace SKIP 1

COLUMN tablespace FORMAT A25
COLUMN username   FORMAT A25
COLUMN usage      FORMAT 999,999,999
COLUMN quota      FORMAT 999,999,999
COLUMN percent    FORMAT 9,999.9

COMPUTE SUM OF usage ON tablespace
COMPUTE SUM OF quota ON tablespace

SELECT 
    dbatq.tablespace_name tablespace, 
    dbatq.username,
    dbatq.bytes usage, 
    DECODE(dbatq.max_bytes, -1, 0, dbatq.max_bytes) quota,
    DECODE(dbatq.max_bytes, -1, '*', ' ') u
FROM 
    dba_ts_quotas dbatq, 
    dba_users dbau, 
    dba_tablespaces dbat
WHERE
    dbau.username LIKE NVL(UPPER('&&usr'), '%')
    AND dbat.tablespace_name LIKE NVL(UPPER('&&ts'), '%')
    AND dbau.username = dbatq.username
    AND dbat.tablespace_name = dbatq.tablespace_name
    AND dbat.status = 'ONLINE'
    AND (dbatq.bytes > 0 or dbatq.max_bytes > 0)
ORDER BY 
    dbatq.tablespace_name, 
    dbatq.username
;

UNDEFINE usr ts

@_END
