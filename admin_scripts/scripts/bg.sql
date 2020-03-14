REM
REM  Displays activated Oracle background processes
REM

@_BEGIN
@_TITLE "ACTIVATED BACKGROUND PROCESSES"

COLUMN paddr        FORMAT A16
COLUMN name         FORMAT A5
COLUMN description  FORMAT A40 WORD
COLUMN error        FORMAT 90

SELECT
    paddr,
    name,
    description,
    error
FROM
    v$bgprocess
WHERE
    LTRIM(REPLACE(paddr, '0')) IS NOT NULL
;

@_END
