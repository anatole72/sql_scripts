REM 
REM  Deallocate unused space from table segments
REM  Author: Mark Lang, 1998
REM 
REM  Notes:   Only dealloc segments of <min_kb> size or larger.
REM           Use with caution!
REM           Add functionality to specify KEEP parameter?
REM

@_BEGIN
SET ECHO OFF
SET FEEDBACK OFF
SET PAGESIZE 0

PROMPT
PROMPT DEALLOCATE UNUSED SPACE FROM TABLE SEGMENTS
PROMPT
ACCEPT own PROMPT "Segment owner like (ENTER for all): "
ACCEPT nam PROMPT "Segment name like (ENTER for all): "
PROMPT
PROMPT Allowed segment types:
PROMPT

SELECT DISTINCT segment_type
FROM dba_segments
WHERE
    owner LIKE NVL(UPPER('&&own'), '%')
    AND segment_name LIKE NVL(UPPER('&&nam'), '%')
ORDER BY segment_type;

PROMPT
ACCEPT typ PROMPT "Segment type like (ENTER for all): "
PROMPT
PROMPT Allowed tablespaces:
PROMPT

SELECT DISTINCT tablespace_name
FROM dba_segments
WHERE
    owner LIKE NVL(UPPER('&&own'), '%')
    AND segment_name LIKE NVL(UPPER('&&nam'), '%')
    AND segment_type LIKE NVL(UPPER('&&typ'), '%')
ORDER BY tablespace_name;

PROMPT
ACCEPT ts  PROMPT "Segment tablespace like (ENTER for all): "
ACCEPT kb  PROMPT "Minimal segment size (Kb, ENTER for 0): " NUMBER
PROMPT

SPOOL &SCRIPT
SELECT
    'ALTER '
    || segment_type
    || ' '
    || owner
    || '.'
    || segment_name
    || ' DEALLOCATE UNUSED;'
FROM
    sys.dba_segments
WHERE
    owner LIKE NVL(UPPER('&&own'), '%')
    AND segment_name LIKE NVL(UPPER('&&nam'), '%')
    AND segment_type LIKE NVL(UPPER('&&typ'), '%')
    AND tablespace_name LIKE NVL(UPPER('&&ts'), '%')
    AND bytes / 1024 >= &&kb
ORDER BY
    owner,
    segment_name
;
SPOOL OFF

@_CONFIRM "deallocate unused"
@_BEGIN
SET ECHO ON
SET FEEDBACK ON

@&SCRIPT

SET ECHO OFF
SET FEEDBACK OFF

UNDEFINE own nam typ ts kb

@_END

