REM
REM  User login times
REM

@_BEGIN
@_TITLE 'User Login Times'

COLUMN sids     FORMAT A10 HEADING "Sid,Ser#"
COLUMN username FORMAT A16 HEADING Username
COLUMN ltime    FORMAT A20 HEADING "Login Time"
COLUMN program  FORMAT A21 HEADING Program

SELECT 
    s.sid || ',' || n.serial# sids,
    n.username,
    n.status "Status",
    n.program,
    TO_CHAR(SYSDATE - (hsecs - s.value) / (24 * 3600 * 100),
        'DD-MON-YYYY HH24:MI:SS') ltime
FROM 
    sys.v_$sesstat s,
    sys.v_$session n,
    sys.v_$timer
WHERE 
    s.statistic# = 13
    AND s.sid = n.sid
    /* AND s.value != 0 */
ORDER BY 
    2, 5
;
@_END
