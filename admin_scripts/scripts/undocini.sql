REM
REM Getting undocumented INIT.ORA parameters (7.3 and 8.0)
REM
REM The script should be executed in SYS account.
REM


@_BEGIN
@_TITLE "UNDOCUMENTED INIT.ORA PARAMETERS (7.3)"

COLUMN Param HEADING "Undocumented|Parameter" FORMAT A33
COLUMN Descr HEADING "Parameter|Description"  FORMAT A34 WORD_WRAPPED
COLUMN Value HEADING "Session|Value"          FORMAT A10

SELECT
    a.ksppinm  Param,
    a.ksppdesc Descr,
    b.ksppstvl Value 
FROM
    x$ksppi  a,
    x$ksppcv b
WHERE
    a.indx = b.indx
    AND a.ksppinm LIKE '\_%' ESCAPE '\'
ORDER BY 
    1
/

@_END
