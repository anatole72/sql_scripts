REM
REM The following script lists the number of waits for each rollback
REM segment as well as the number of gets and active transactions
REM using the rollback segment.
REM

@_BEGIN
@_TITLE "ROLLBACK SEGMENTS WAIT STATISTICS"
SELECT
    name  "Rollback Segment",
    gets  "Gets",
    waits "Waits",
    TO_CHAR((waits / gets) * 100, '990.99') "Waits%",
    TO_CHAR((gets - waits) * 100 / gets, '990.99') "HitRat%",
    xacts "Active TX"
FROM
    v$rollstat s,
    v$rollname r
WHERE
    s.usn = r.usn
ORDER BY
    name
;

REM
REM The following script lists the number of waits for the rollback 
REM segment header (undo header) and the rollback segment blocks.
REM

@_TITLE "ROLLBACK SEGMENTS WAITS"
SELECT 
    class, 
    count 
FROM 
    v$waitstat
WHERE 
    class IN ('undo header', 'undo block')
;
@_END
