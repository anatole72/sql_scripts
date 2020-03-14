REM 
REM    Currently, there is no direct way of querying the data dictionary
REM    and finding out the time for which a certain session has been idle
REM    or inactive.  But the database does provide ways to collect this
REM    information.  This information is usually very important for the
REM    DBAs, as idle sessions consume resources and hence affect
REM    performance.
REM
REM    A session is considered to be inactive or idle when the connection
REM    with the database is still established but there is no communication
REM    going on between the client and the server. In this case, client
REM    refers to any tool or application that allows you to connect to the
REM    RDBMS.
REM
REM    This bulletin provides a way of extracting this information from the
REM    data dictionary.
REM
REM    =============
REM    Requirements:
REM    =============
REM
REM    In order to monitor idle times successfully, the following
REM    steps must be carried out.
REM
REM    (1)     Set the init.ora parameter RESOURCE_LIMIT to TRUE to enable
REM            the enforcement of resource limits.
REM
REM    (2)     Shutdown and startup again to enable the changes made to the
REM            init.ora file.
REM
REM    (3)     Create a user_profile and set the idle_time parameter
REM            to a certain value (minutes).
REM
REM    (4)     Make this user_profile the default profile of the user
REM            or users whose sessions are to be monitored.
REM
REM    NOTE:   Different users may have different user_profiles as
REM            their default profiles.
REM 
REM    ========
REM    Example:
REM    ========
REM                                                  idle-time    idle-time
REM    SID Last non-idle time  Current time          (seconds)    (minutes)
REM    --- ------------------- ------------------ ------------ ------------
REM      1 01-jul-94 12:21:52  06-nov-94 03:38:10 11070977.710 184516.29517
REM      2 06-nov-94 03:38:07  06-nov-94 03:38:1         3.000       .05000
REM      3 06-nov-94 01:06:27  06-nov-94 03:38:1      9102.970    151.71617
REM      4 06-nov-94 03:36:56  06-nov-94 03:38:1        73.620      1.22700
REM      5 06-nov-94 03:37:49  06-nov-94 03:38:1        20.910       .34850
REM
REM    Run the query again after a few seconds:
REM
REM                                                  idle-time    idle-time
REM    SID Last non-idle time  Current time          (seconds)    (minutes)
REM    --- ------------------- ------------------ ------------ ------------
REM      1 01-jul-94 12:21:53  06-nov-94 03:40:15 11071102.050 184518.36750
REM      2 06-nov-94 03:40:12  06-nov-94 03:40:15        3.400       .05667
REM      3 06-nov-94 01:06:28  06-nov-94 03:40:15     9227.320    153.78867
REM      4 06-nov-94 03:36:57  06-nov-94 03:40:15      197.970      3.29950
REM      5 06-nov-94 03:37:50  06-nov-94 03:40:15      145.260      2.42100
REM
REM    Run the query again after a few seconds:
REM
REM                                                  idle-time    idle-time
REM    SID Last non-idle time  Current time          (seconds)    (minutes)
REM    --- ------------------- ------------------ ------------ ------------
REM      1 01-jul-94 12:21:53  06-nov-94 03:40:51 11071138.300 184518.97167
REM      2 06-nov-94 03:40:11  06-nov-94 03:40:51       39.650       .66083
REM      3 06-nov-94 01:06:27  06-nov-94 03:40:51     9263.570    154.39283
REM      4 06-nov-94 03:36:5   06-nov-94 03:40:51      234.220      3.90367
REM      5 06-nov-94 03:37:49  06-nov-94 03:40:51      181.510      3.02517
REM
REM    When the RESOURCE_LIMIT parameter is set to true, then for each
REM    user who has a profile with idle_time defined, oracle records the
REM    entry of V$TIMER as soon as a session of that user becomes inactive.
REM    This recorded value of V$TIMER can later be used to find out the
REM    exact amount of time for which the session has been idle. This is
REM    exactly what the above example demonstrate.
REM
REM    Let us look at SID = 3 in the result of the last query.  The "last
REM    non-idle time" for this session is also the time when this session
REM    became inactive, which happened at 06-nov-94 01:06:27.  From the
REM    "Current time" column, we know what the current time is.  Hence, it
REM    is easy to calculate the time for which the session has been idle.
REM    This information is available from columns 4 and 5.
REM
REM    Notice that V$TIMER starts at 0 when the database is created.  The
REM    SID 1 IS not relevent in this case as its idle_time timer stopped
REM    at t=0, hence it appears to be idle since the creation of the
REM    database. These entries correspond to the background processes.
REM
REM    NOTE:
REM    ----
REM
REM    A session will continue to show as idle even after the idle_time
REM    for that user, as specified in that user's profile, has expired.
REM    When the user attempts to run a transaction against the database
REM    after the idle_time has expired, the database will disconnect the
REM    user by terminating the session. After this, the session will no
REM    longer show in the output of the above query.
REM

@_BEGIN
@_TITLE "Sessions idle time"

COLUMN sid  FORMAT 9999
COLUMN last FORMAT A22 HEADING "Last non-idle time"
COLUMN curr FORMAT A22 HEADING "Current time"
COLUMN secs FORMAT 99999999.999 HEADING "idle-time|(seconds)"
COLUMN mins FORMAT 999999.99999 HEADING "idle-time|(minutes)"

SELECT 
    sid, 
    TO_CHAR((SYSDATE - (hsecs - value) / (100 * 60 * 60 * 24)),
        'DD-MON-YY HH24:MI:SS') last, 
    TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI:SS') curr,
    (hsecs - value) / (100) secs, 
    (hsecs - value) / (100 * 60) mins
FROM 
    v$timer, 
    v$sesstat
WHERE 
    statistic# = (
        SELECT statistic# 
        FROM v$statname
        WHERE name = 'process last non-idle time'
    )
;
@_END

