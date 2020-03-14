REM 
REM  Performs advanced ANALYZE operations
REM

PROMPT
PROMPT ADVANCED ANALYZE OPERATIONS
PROMPT

ACCEPT own PROMPT "Schema name like (ENTER for all): "
ACCEPT obj PROMPT "Object name like (ENTER for all): "
ACCEPT typ PROMPT "Object type ((T)able, (I)ndex, (C)luster, ENTER for all): "

PROMPT
PROMPT POSSIBLE ANALYZE ACTION:
PROMPT
PROMPT D  = delete statistics
PROMPT
PROMPT E  = estimate statistics
PROMPT ET = estimate statistics for table
PROMPT EI = estimate statistics for all indexes
PROMPT EL = estimate statistics for all indexed columns
PROMPT
PROMPT C  = compute statistics
PROMPT CT = compute statistics for table
PROMPT CI = compute statistics for all indexes
PROMPT CL = compute statistics for all indexed columns
PROMPT
PROMPT VS = validate structure
PROMPT VC = validate structure cascade
PROMPT LC = list chained rows
PROMPT
ACCEPT act PROMPT "Statistics action: "
PROMPT

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

DEFINE cr = "CHR(10)"
DEFINE ty = "UPPER('&&typ%')"
DEFINE ac = "UPPER('&&act')"
DEFINE ft = "DECODE(o.object_type, 'TABLE', 'FOR TABLE')"
DEFINE fi = "DECODE(o.object_type, 'TABLE', 'FOR ALL INDEXES')"
DEFINE fc = "DECODE(o.object_type, 'TABLE', 'FOR ALL INDEXED COLUMNS')"

SPOOL &SCRIPT

SELECT
    'ANALYZE ' || o.object_type || ' ' || o.owner || '.' || o.object_name || &&cr ||
    DECODE(&&ac,
        'D' , 'DELETE STATISTICS',
        'E' , 'ESTIMATE STATISTICS',
        'ET', 'ESTIMATE STATISTICS ' || &&ft,
        'EI', 'ESTIMATE STATISTICS ' || &&fi,
        'EC', 'ESTIMATE STATISTICS ' || &&fc,
        'C' , 'COMPUTE STATISTICS',
        'CT', 'COMPUTE STATISTICS '  || &&ft,
        'CI', 'COMPUTE STATISTICS '  || &&fi,
        'CC', 'COMPUTE STATISTICS '  || &&fc,
        'VS', 'VALIDATE STRUCTURE',
        'VC', 'VALIDATE STRUCTURE CASCADE',
        'LC', 'LIST CHAINED ROWS'
    ) || ';'
FROM
    dba_objects o
WHERE
    o.owner NOT IN ('SYS', 'SYSTEM')
    AND o.owner LIKE NVL(UPPER('&&own'), '%')
    AND o.object_name LIKE NVL(UPPER('&&obj'), '%')
    AND o.object_type LIKE &&ty
    AND o.object_type IN ('TABLE', 'INDEX', 'CLUSTER')
ORDER BY
    o.owner,
    o.object_name
;
SPOOL OFF

@_CONFIRM "analyze"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE own obj typ act cr ty ac ft fi fc

@_END

