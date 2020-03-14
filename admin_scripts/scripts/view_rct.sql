REM
REM  Recreate database views by owner
REM 
REM  If your view definitions are greater than 5000 characters
REM  increase the set long. This can be determined by
REM  querying the DBA_VIEWS table's text_length column for the
REM  max value: select max(text_length) from dba_views;
REM

PROMPT
PROMPT RECREATE VIEWS
PROMPT

ACCEPT owner_name PROMPT "View owner like (ENTER for all): "
ACCEPT view_name  PROMPT "View name like (ENTER for all): "
PROMPT

@_BEGIN
SET PAGESIZE 0
SET LONG 5000
DEFINE CR = 'CHR(10)'

COLUMN text FORMAT A80 WORD_WRAPPED
COLUMN view_name FORMAT A20

SELECT 
    DECODE(rownum, 1, '', '/' || &&CR)
    || 'CREATE OR REPLACE VIEW '
    || v.owner
    || '.'
    || v.view_name
    || ' AS '
    || &&CR,
    v.text
FROM 
    dba_views v 
WHERE 
    v.owner LIKE NVL(UPPER('&owner_name'), '%')
    AND view_name LIKE NVL(UPPER('&view_name'), '%')
ORDER BY 
    v.view_name;

SELECT
    '/'
FROM
    sys.dual
WHERE EXISTS (
    SELECT 
        0
    FROM 
        dba_views v 
    WHERE 
        v.owner LIKE NVL(UPPER('&owner_name'), '%')
        AND view_name LIKE NVL(UPPER('&view_name'), '%')
);

@_END
