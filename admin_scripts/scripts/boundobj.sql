REM
REM Report on objects with extents bounded by freespace
REM

@_BEGIN
@_TITLE "Objects With Extents Bounded by Free Space"

COLUMN e FORMAT A18         HEADING "Tablespace"
COLUMN a FORMAT A6          HEADING "Object|Type"
COLUMN b FORMAT A30         HEADING "Object Name"
COLUMN c FORMAT A10         HEADING "Owner"
COLUMN d FORMAT 99,999,999  HEADING "Size|in bytes"
BREAK ON e SKIP 1 ON c 

SET FEEDBACK OFF
SET VERIFY OFF
SET TERMOUT OFF

COLUMN bls NEW_VALUE block_size NOPRINT
SELECT 
    blocksize bls
FROM 
    sys.ts$
WHERE 
    name = 'SYSTEM'
;
@_SET

SELECT 
    h.name e, 
    g.name c, 
    f.object_type a, 
    e.name b, 
    b.length * &&block_size d
FROM 
    sys.uet$ b, 
    sys.fet$ c, 
    sys.fet$ d, 
    sys.obj$ e, 
    sys.sys_objects f, 
    sys.user$ g, 
    sys.ts$ h
WHERE 
    b.block# = c.block# + c.length
    AND b.block# + b.length = d.block#
    AND f.header_file = b.segfile#
    AND f.header_block = b.segblock#
    AND f.object_id = e.obj#
    AND g.user# = e.owner#
    AND b.ts# = h.ts#
ORDER BY 
    1, 2, 3, 4
/
@_END

