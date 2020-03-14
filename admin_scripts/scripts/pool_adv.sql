REM
REM  Calculates recommended size of Shared Pool based on # of users
REM  Author: Mark Lang, 1998
REM

@_BEGIN
SET HEADING OFF

PROMPT
PROMPT RECOMMENDED SIZE OF SHARED POOL BASED ON # OF USERS
PROMPT
ACCEPT nu PROMPT "Number of users: " NUMBER

VARIABLE n_a NUMBER
VARIABLE n_b NUMBER
VARIABLE n_c NUMBER

BEGIN
    SELECT AVG(value) * &&nu
    INTO :n_a
    FROM v$sesstat s, v$statname n
    WHERE s.statistic# = n.statistic#
    AND n.name = 'session uga memory max';

    SELECT SUM(sharable_mem)
    INTO :n_b
    FROM v$sqlarea;

    SELECT
    SUM(sharable_mem)
    INTO :n_c
    FROM v$db_object_cache;
END;
/

SELECT
    'Recommeded size of shared pool: '
    || TO_CHAR((:n_a + :n_b + :n_c
        + (:n_a + :n_b + :n_c) * 0.3) / (1024 * 1024), 'fm999990.99') || 'M'
FROM SYS.DUAL;

@_END
