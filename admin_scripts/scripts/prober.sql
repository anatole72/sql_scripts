REM
REM  Quick tuning prober
REM 

@_BEGIN

DEFINE p = SUM(pins) 
DEFINE r = SUM(reloads) 
DEFINE m = &r/&p*100 
 
SELECT
    &p pins,
    &r reloads,
    &m "MISS RATE", 
    DECODE(SIGN(&m - 1), 1, 'Increase SHARED_POOL_SIZE', 'OK') comments 
FROM
    v$librarycache 
/

UNDEFINE p r m

DEFINE g = SUM(gets) 
DEFINE m = SUM(getmisses) 
DEFINE mi = &m/&g*100 

SELECT
    &g gets,
    &m getmisses,
    &mi "MISS RATE", 
        DECODE(SIGN(&mi - 10), 1, 'Increase SHARED_POOL_SIZE','OK') comments 
FROM
    v$rowcache 
/ 

UNDEFINE g m mi

DEFINE p = SUM(DECODE(statistic#,39,value,0)) 
DEFINE l = SUM(DECODE(statistic#,37,value,38,value,0)) 
DEFINE h = (1-(&p/&l))*100

SELECT
    &p physical,
    &l logical,
    &h "HIT RATE", 
    DECODE(SIGN(&h - 70),
        -1 , 'Increase DB_BLOCK_BUFFER', 
        DECODE(SIGN(&h - 95),
            1, 'Decrease DB_BLOCK_BUFFER',
            'OK'
        )
    ) comments 
FROM
    v$sysstat 
/

UNDEFINE p l h 
 
COLUMN disk FORMAT 99,999,999 
DEFINE m = SUM(DECODE(statistic#,121,value,0)) 
DEFINE d = SUM(DECODE(statistic#,122,value,0)) 
DEFINE r = SUM(DECODE(statistic#,123,value,0))

SELECT
    &m "MEMORY", 
    &d "DISK",  
    &r "ROWS",
    DECODE(SIGN((&d) - (&m)), 1, 'Increase SORT_AREA_SIZE', 'OK') comments
FROM
    v$sysstat 
/

UNDEFINE m d r
 
DEFINE t = SUM(DECODE(statistic#,4,DECODE(value,0,1,value),0)) 
DEFINE l = SUM(DECODE(statistic#,0,DECODE(value,0,1,value),0)) 
DEFINE e = SUM(DECODE(statistic#,23,value,0)) 

SELECT
    &e "ENQUEUE WAITS", 
    &e / &t "PER TRANSACTION", 
    &e / &l "PER LOGON" , 
    DECODE(SIGN((&e / &t) - 1), 1, 'Increase ENQUEUE_RESOURCES', 'OK') comments 
FROM
    v$sysstat 
/

UNDEFINE t l e
 
DEFINE t = SUM(DECODE(statistic#,4,DECODE(value,0,1,value),0)) 
DEFINE l = SUM(DECODE(statistic#,0,DECODE(value,0,1,value),0)) 
DEFINE e = SUM(DECODE(statistic#,58,value,0))

SELECT
    &e "DBWR CHECKPOINTS", 
    &e / &t "PER TRANSACTION", 
    &e / &l "PER LOGON" , 
    DECODE(SIGN((&e / &t) - 1), 1, 'Increase LOG_CHECKPOINT_INTERVAL', 'OK') comments 
FROM
    v$sysstat 
/

UNDEFINE t l e
 
DEFINE t = SUM(DECODE(statistic#,4,DECODE(value,0,1,value),0)) 
DEFINE l = SUM(DECODE(statistic#,0,DECODE(value,0,1,value),0)) 
DEFINE e = SUM(DECODE(statistic#,83,value,0))

SELECT
    &e "REDO LOG SPACE REQUESTS", 
    &e / &t "PER TRANSACTION", 
    &e / &l "PER LOGON" , 
    DECODE(SIGN((&e / &t) - 1), 1, 'Increase LOG_BUFFER', 'OK') comments 
FROM
    v$sysstat 
/

UNDEFINE t l e
 
@_END
