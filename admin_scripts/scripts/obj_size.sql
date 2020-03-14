REM 
REM  Display stored objects size information
REM 

PROMPT
PROMPT STORED OBJECTS SIZES
PROMPT

ACCEPT own PROMPT "Object owner like (ENTER for all): "
ACCEPT nam PROMPT "Object name like (ENTER for all): "
ACCEPT typ PROMPT "Object type like (ENTER for all): "
ACCEPT ord -
    PROMPT "Order by ((N)ame, (T)ype; (S)ource, (P)arsed, (C)ode size): "

@_BEGIN
@_TITLE "Stored objects sizes"

COLUMN oname    FORMAT A30      HEADING "OBJECT NAME"
COLUMN type     FORMAT A12      HEADING "TYPE"
COLUMN source   FORMAT 999,990  HEADING "SOURCE"
COLUMN parsed   FORMAT 999,990  HEADING "PARSED"
COLUMN code     FORMAT 999,990  HEADING "CODE"
COLUMN error    FORMAT 999,990  HEADING "ERROR"

SELECT
    owner || '.' || name oname,
    type,
    source_size source,
    parsed_size parsed,
    code_size code,
    error_size error
FROM
    sys.dba_object_size
WHERE
    owner LIKE NVL(UPPER('&&own'), '%') 
    AND name LIKE NVL(UPPER('&&nam'), '%')
    AND type LIKE NVL(UPPER('&&typ'), '%')
ORDER BY
    DECODE(UPPER('&&ord'),
        'N', owner || '.' || name,
        'T', type,
        'S', TO_CHAR(999999999999 - source_size),
        'P', TO_CHAR(999999999999 - parsed_size),
        'C', TO_CHAR(999999999999 - code_size),
        owner || '.' || name)
;

UNDEFINE own nam typ ord

@_END
