REM 
REM  Display VSIZE of column
REM 

@_BEGIN

PROMPT
PROMPT AVERAGE SIZE OF COLUMN
PROMPT
ACCEPT own PROMPT "Table owner: "
ACCEPT nam PROMPT "Table name: "
ACCEPT clm PROMPT "Column name: "

SET HEADING OFF
SELECT
    'Average size of '
    || UPPER('&&own..&&nam(&&clm)')
    ||' is '
    || AVG(VSIZE(&&clm))
    || ' bytes'
FROM
    &&own..&&nam
;
@_END

