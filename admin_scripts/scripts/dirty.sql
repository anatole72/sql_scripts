REM
REM  Reports statistics about the buffers in the SGA. It will print 
REM  the information about the types of buffers in the SGA, how many of 
REM  them are on the dirty queue and how many are not.
REM
REM  The script has to be executed in SYS account.
REM

@_BEGIN
@_TITLE 'DIRTY BUFFERS'

COLUMN class    FORMAT A10 
COMPUTE SUM LABEL Total OF "Total" ON REPORT

SELECT
    DECODE(GREATEST(class, 10),
        10, DECODE(class,
            1, 'Data',
            2, 'Sort',
            4, 'Header',
            TO_CHAR(class)),
        'Rollback') "Class", 
    SUM(DECODE(BITAND(flag, 1), 1, 0, 1)) "Not Dirty", 
    SUM(DECODE(BITAND(flag, 1), 1, 1, 0)) "Dirty", 
    SUM(dirty_queue) "On Dirty",
    COUNT(*) "Total" 
FROM
    x$bh 
GROUP BY
    DECODE(GREATEST(class, 10),
        10, DECODE(class,
        1, 'Data',
        2, 'Sort',
        4, 'Header',
        TO_CHAR(class)),
    'Rollback') 
/ 

@_END
