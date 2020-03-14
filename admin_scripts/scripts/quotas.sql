REM
REM  Print the tablespace quotas of users 
REM

PROMPT
PROMPT TABLESPACES QUOTAS BY USER
PROMPT
ACCEPT usr PROMPT "User name like (ENTER for all): "
ACCEPT ts  PROMPT "Tablespace name like (ENTER for all): "

@_BEGIN
@_TITLE "DATABASE USERS SPACE QUOTAS BY USERS"

COLUMN un 	FORMAT A28 		    HEADING 'User Name'
COLUMN ta 	FORMAT A28 		    HEADING 'Tablespace' 
COLUMN usd	FORMAT 9,999,999 	HEADING 'Used KB' 
COLUMN maxb	FORMAT A10		    HEADING 'Limit KB' 
BREAK ON un SKIP 1
COMPUTE SUM OF usd ON un

SELECT 
    username un,
    tablespace_name ta,
    bytes / 1024 usd, 
    DECODE (max_bytes, 
        -1, 'UNLIMITED', 
        TO_CHAR(max_bytes / 1024, '9,999,999')
    ) maxb
FROM 
    dba_ts_quotas
WHERE
    username LIKE NVL(UPPER('&&usr'), '%')
    AND tablespace_name LIKE NVL(UPPER('&&ts'), '%')
ORDER BY 
    username,
    tablespace_name
;
UNDEFINE ust ts
@_END
