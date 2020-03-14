REM 
REM Perform ANALYZE TABLE... ESTIMATE... on multiple tables
REM

PROMPT
PROMPT ANALYZING TABLES WITH STATISTICS ESTIMATION
PROMPT

ACCEPT own PROMPT "Table owner like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "
ACCEPT pct PROMPT "How many rows to analyze (ENTER if none, 1..100 if %, >100 if rows): "
DEFINE per = "DECODE('&&pct', NULL, '' , '*', '' , '%', '', '0', '', -
' SAMPLE &&pct ' || DECODE(SIGN(TO_NUMBER('&&pct') - 100), 1, 'ROWS', 'PERCENT'))"

@_BEGIN
SET HEADING OFF
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SPOOL &SCRIPT
SELECT
    'PROMPT Analyzing ' || o.owner || '.' || o.object_name || '...' || &&CR ||  
    'ANALYZE ' || o.object_type || ' ' || o.owner || '.' || o.object_name || &&CR ||
    'ESTIMATE STATISTICS FOR TABLE' || &&per || ';' || &&CR ||
    'ANALYZE ' || o.object_type || ' ' || o.owner || '.' || o.object_name || &&CR ||
    'ESTIMATE STATISTICS FOR ALL INDEXES' || &&per || ';' || &&CR ||
    'ANALYZE ' || o.object_type || ' ' || o.owner || '.' || o.object_name || &&CR ||
    'ESTIMATE STATISTICS FOR ALL INDEXED COLUMNS' || &&per || ';'
FROM
    dba_objects o 
WHERE
    o.owner NOT IN ('SYS','SYSTEM')
    AND o.owner LIKE NVL(UPPER('&&own'), '%')
    AND o.object_name LIKE NVL(UPPER('&&nam'), '%')
    AND o.object_type = 'TABLE'
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

UNDEFINE own nam pct per

@_END

