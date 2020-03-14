REM
REM  This simple script lists how many tables are analyzed and how
REM  many aren't. If you are using the COST based optimizer, having some
REM  analyzed and others not in a table join can cause horrendous 
REM  performance.
REM
REM  Author: Mark Gurry
REM

@_BEGIN
@_TITLE "Tables that Are Analyzed (Summary by Owner)"

SELECT 
    owner, 
    SUM(DECODE(NVL(num_rows, 9999), 9999, 0, 1)) "Tables Analyzed",
    SUM(DECODE(NVL(num_rows, 9999), 9999, 1, 0)) "Tables NOT ANALYZED"
FROM
    dba_tables
WHERE 
    owner NOT IN ('SYS', 'SYSTEM')
GROUP BY 
    owner
;

@_END
