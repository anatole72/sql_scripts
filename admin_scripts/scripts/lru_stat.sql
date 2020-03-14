REM 
REM  Display buffer cache statistics in X$KCBRBH and X$KCBCBH
REM 
REM  This script can only be run as SYS. Otherwise, you will get
REM  a "table or view does not exist" error.
REM 
REM  Author:  Mark Lang, 1998
REM 

@_BEGIN

PROMPT
PROMPT Displays hit ratio based on increased or decreased buffer cache
PROMPT based on X$KCBRBH and X$KCBCBH tables.
PROMPT
PROMPT This script can only be run as SYS. Otherwise, you will get
PROMPT a "table or view does not exist" error.

@_CONFIRM "continue"
PROMPT
ACCEPT int PROMPT "Interval: " NUMBER
PROMPT

COLUMN "Interval"   FORMAT A14
COLUMN "Cache Hits" FORMAT A12
COLUMN "Hit Ratio"  FORMAT A9

VAR n_a NUMBER
VAR n_b NUMBER
VAR n_c NUMBER
VAR n_d NUMBER
VAR n_e NUMBER
VAR n_f NUMBER

BEGIN

    SELECT
        SUM(DECODE(name, 'db block gets', value, 0)),
        SUM(DECODE(name, 'consistent gets', value, 0)),
        SUM(DECODE(name, 'physical reads', value, 0))
    INTO :n_a, :n_b, :n_c
    FROM v$sysstat;

    SELECT value, value
    INTO :n_d, :n_e
    FROM v$parameter
    WHERE name = 'db_block_buffers';
    
    SELECT
        (1 - (:n_d / (:n_a + :n_b))) * 100 INTO :n_f
    FROM sys.dual;

END;
/

SELECT
    TO_CHAR(&&int * TRUNC(indx / &&int) + 1, '99990')
    || ' to ' ||
    TO_CHAR(DECODE(TRUNC(&&int * (TRUNC(indx / &&int) + 1) / :n_d), 0,
        &&int * (TRUNC(indx / &&int) + 1), :n_e), '99990') "Interval",
    TO_CHAR(SUM(count), '999,999,990') "Cache Hits",
    TO_CHAR(-(SUM(count) / (:n_a + :n_b)) * 100, '99990.99') "Hit Ratio"
FROM x$kcbcbh
GROUP BY TRUNC(indx/&&int);

SET HEADING OFF

SELECT
    TO_CHAR(:n_d, '9990') "Interval",
    TO_CHAR(:n_c, '999,999,990') "Cache Hits",
    TO_CHAR(:n_f, '99990.99') "Hit Ratio"
FROM sys.dual;

SELECT
    TO_CHAR(&&int * TRUNC(indx / &&int) + 1, '9990')
    || ' to ' ||
    TO_CHAR(&&int * (TRUNC(indx / &&int) + 1), '9990') "Interval",
    TO_CHAR(SUM(count), '999,999,990') "Cache Hits",
    TO_CHAR((SUM(count) / (:n_a + :n_b)) * 100, '99990.99') "Hit Ratio"
FROM x$kcbrbh
GROUP BY TRUNC(indx / &&int);

UNDEFINE int

@_END

