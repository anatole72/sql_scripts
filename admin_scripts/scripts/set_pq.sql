REM 
REM  Set PARALLEL characteristics of tables
REM 

PROMPT
PROMPT SET PARALLEL CHARACTERISTICS OF TABLES
PROMPT

ACCEPT own PROMPT "Table owner like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "
ACCEPT deg PROMPT "Degree (number, (D)efault, ENTER for none): "
ACCEPT ins PROMPT "Instances (number, (D)efault, ENTER for none): "

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
    'ALTER TABLE '
    || owner || '.' || table_name
    || &&CR
    || 'PARALLEL ('
    || DECODE(UPPER('&&deg'),
        'D', 'DEGREE DEFAULT ',
        NULL, NULL,
        'DEGREE ' || '&&deg' || ' ')
    || DECODE(UPPER('&&ins'),
        'D', 'INSTANCES DEFAULT ',
        NULL, NULL,
        'INSTANCE ' || '&&ins' ||' ')
    || ');'
FROM
    dba_tables
WHERE
    ('&&deg' IS NOT NULL OR '&&ins' IS NOT NULL)
    AND owner LIKE NVL(UPPER('&&own') ,'%')
    AND owner NOT IN ('SYS', 'SYSTEM')
    AND table_name LIKE NVL(UPPER('&&nam') ,'%')
ORDER BY
    owner,
    table_name
;
SPOOL OFF

@_CONFIRM "alter table"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE own nam deg ins

@_END


