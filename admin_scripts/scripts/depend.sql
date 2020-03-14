REM
REM  Tries to determine what objects an objects depends on and create
REM  an immediate dependency chart.
REM
REM  OBJECT:
REM     'Dropped?' implies an object we depend on has been
REM     dropped. We cannot tell what was dropped.
REM
REM  TYPE:
REM     '*Not Exist*' implies we rely on such a named object
REM     NOT existing. If one comes into existance we need to
REM     recompile.  The TIMESTAMP for 'Not Exists' type
REM     objects is set to Oracles END-OF-TIME.
REM
REM  TIMESTAMP:
REM     *SAME*   Shows timestamp on object looks fine.
REM              NOTE that for '*Not Exist*' this can't give a
REM              true indication.
REM     *NEWER*  Named object is newer than the last recompile
REM              of this object.
REM     *OLDER*  Usually means an item that did not exist has
REM              been created thus meaning we need a recompile.
REM

PROMPT
PROMPT WHAT OBJECTS AN OBJECTS DEPENDS ON IMMEDIATELY
PROMPT
ACCEPT own CHAR PROMPT "Object owner like: "
ACCEPT nam CHAR PROMPT "Object name like: "

@_BEGIN
@_TITLE "OBJECTS MATCHING &&own..&&nam"

COLUMN obj#	    FORMAT 99999	HEADING "Obj ID"
COLUMN object   FORMAT A42      HEADING "Object Name"
COLUMN type	    FORMAT A11      HEADING "Type"	
COLUMN status	FORMAT A7       HEADING "Status"

SELECT 
    o.obj# "obj#",
    DECODE(o.linkname, 
        NULL, u.name || '.' || o.name,
        o.remoteowner || '.' || o.name || '@' || o.linkname
    ) "object",
    DECODE(o.type, 
        0,  'NEXT OBJECT', 
        1,  'INDEX', 
        2,  'TABLE', 
        3,  'CLUSTER',
        4,  'VIEW', 
        5,  'SYNONYM', 
        6,  'SEQUENCE',
        7,  'PROCEDURE', 
        8,  'FUNCTION', 
        9,  'PACKAGE',
        10, '*Not Exist*',
        11, 'PKG BODY', 
        12, 'TRIGGER', 
        'UNDEFINED'
    ) "type",
    DECODE(o.status,
        0, 'N/A',
        1, 'VALID', 
        'INVALID'
    ) "status"
FROM 
    sys.obj$ o, 
    sys.user$ u
WHERE 
    owner# = user#
    AND u.name LIKE UPPER('&&own')
    AND o.name LIKE UPPER('&&nam')
;

PROMPT
ACCEPT OBJID CHAR PROMPT "Enter Object ID required: "
@_TITLE "OBJECT &&OBJID IS"
COLUMN "S-Time" FORMAT A9 WORD_WRAP

SELECT 
    o.obj# "obj#",
    DECODE(o.linkname, 
        NULL, u.name || '.' || o.name,
        o.remoteowner|| '.' || o.name || '@' || o.linkname) "object",
    DECODE(o.type, 
        0,  'NEXT OBJECT', 
        1,  'INDEX', 
        2,  'TABLE', 
        3,  'CLUSTER',
        4,  'VIEW', 
        5,  'SYNONYM', 
        6,  'SEQUENCE',
        7,  'PROCEDURE', 
        8,  'FUNCTION', 
        9,  'PACKAGE',
        10, '*Not Exist*',
        11, 'PKG BODY', 
        12, 'TRIGGER', 
        'UNDEFINED'
    ) "type",
    DECODE(o.status,
        0, 'N/A',
        1, 'VALID', 
        'INVALID') "status",
    SUBSTR(TO_CHAR(stime, 'DD-MON-YY HH24:MI:SS'), 1, 20) "S-Time"
FROM 
    sys.obj$ o, 
    sys.user$ u
WHERE 
    owner# = user# 
    AND o.obj# = '&&objid'
;

@_TITLE "OBJECT &&OBJID DEPENDS ON"

SELECT 
    o.obj# "obj#",
    DECODE(o.linkname, 
        NULL, NVL(u.name, 'Unknown') || '.' || NVL(o.name, 'Dropped?'),
        o.remoteowner || '.' || NVL(o.name, 'Dropped?')
            || '@' || o.linkname) "object",
    DECODE(o.type, 
        0,  'NEXT OBJECT', 
        1,  'INDEX', 
        2,  'TABLE', 
        3,  'CLUSTER',
        4,  'VIEW', 
        5,  'SYNONYM', 
        6,  'SEQUENCE',
        7,  'PROCEDURE', 
        8,  'FUNCTION', 
        9,  'PACKAGE',
        10, '*Not Exist*',
        11, 'PKG BODY', 
        12, 'TRIGGER', 
        'UNDEFINED') "Type",
    DECODE(SIGN(stime - p_timestamp),
        +1, '*NEWER*  ',
        -1, '*OLDER*  ',
        NULL, '-',
        '*SAME*') "TimeStamp",
    DECODE(o.status,
        0, 'N/A',
        1, 'VALID',
        'INVALID') "status"
FROM 
    sys.dependency$ d,  
    sys.obj$ o, 
    sys.user$ u
WHERE 
    p_obj# = obj#(+) 
    AND o.owner# = u.user#(+) 
    AND d_obj# = '&&objid'
;

UNDEFINE own nam objid
@_END
