REM
REM  Run the following SQL script in SQL*Plus while connected 
REM  as SYS or SYSTEM. This will dump a list of all locks held
REM  in the database.
REM

@_BEGIN
@_WTITLE "ALL LOCKS HELD IN THE DATABASE"

COLUMN object           HEADING 'Database Object'   FORMAT A25
COLUMN lock_type        HEADING 'Lock Type'         FORMAT A25
COLUMN mode_held        HEADING 'Mode Held'         FORMAT A20
COLUMN mode_requested   HEADING 'Mode Requested'    FORMAT A19
COLUMN sid              HEADING 'SID'               FORMAT 999
COLUMN username         HEADING 'Username'          FORMAT A20 
COLUMN image            HEADING 'Active Img'        FORMAT A12 

SELECT
    c.sid,
    c.username,
    SUBSTR(c.program, LENGTH(c.program) - 10, LENGTH(c.program)) image,
    SUBSTR(object_name, 1, 10) object,
    DECODE(b.type,
        'MR', 'Media Recovery',
        'RT', 'Redo Thread',
        'UN', 'User Name',
        'TX', 'Transaction',
        'TM', 'DML',
        'UL', 'PL/SQL User Lock',
        'DX', 'Distributed Xaction',
        'CF', 'Control File',
        'IS', 'Instance State',
        'FS', 'File Set',
        'IR', 'Instance Recovery',
        'ST', 'Disk Space Transaction',
        'TS', 'Temp Segment',
        'IV', 'Library Cache Invalidation',
        'LS', 'Log Start or Switch',
        'RW', 'Row Wait',
        'SQ', 'Sequence Number',
        'TE', 'Extend Table',
        'TT', 'Temp Table',
        b.type) lock_type,
    DECODE(b.lmode,
        0, 'None',                  /* Mon Lock equivalent */
        1, 'Null',                  /* NOT */
        2, 'Row-SELECT (SS)',       /* LIKE */
        3, 'Row-X (SX)',            /* R */
        4, 'Share',                 /* SELECT */
        5, 'SELECT/Row-X (SSX)',    /* C */
        6, 'Exclusive',             /* X */
        TO_CHAR(b.lmode)) mode_held,
    DECODE(b.request,
        0, 'None',                  /* Mon Lock equivalent */
        1, 'Null',                  /* NOT */
        2, 'Row-SELECT (SS)',       /* LIKE */
        3, 'Row-X (SX)',            /* R */
        4, 'Share',                 /* SELECT */
        5, 'SELECT/Row-X (SSX)',    /* C */
        6, 'Exclusive',             /* X */
        TO_CHAR(b.request)) mode_requested
FROM 
    sys.dba_objects a, 
    sys.v_$lock b, 
    sys.v_$session c 
WHERE
    a.object_id = b.id1 
    AND b.sid = c.sid 
    AND owner NOT IN ('SYS', 'SYSTEM')
;
@_END
