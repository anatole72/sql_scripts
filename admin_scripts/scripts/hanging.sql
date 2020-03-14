REM
REM  Report objects that need to be recompiled because they may be hanging.
REM
REM  Run from SYS account only.
REM

@_BEGIN
@_TITLE "OBJECTS THAT NEED RECOMPILATION"

COLUMN obj#     HEADING Object|Number
COLUMN name     HEADING Object|Name
COLUMN owner#   HEADING Owner|Number

SELECT DISTINCT 
    o2.obj#,
    o2.name, 
    o2.owner#
FROM 
    sys.obj$ o,
    sys.dependency$ d,
    sys.obj$ o2
WHERE 
    o.obj# = d.p_obj#
    AND o.stime != d.p_timestamp
    AND d.d_obj# = o2.obj#
    AND o2.status != 5
ORDER BY 
    o2.obj#
/

@_END

