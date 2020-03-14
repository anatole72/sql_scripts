@_BEGIN
@_WTITLE "Rollback Segments - Transactions - Statistics"
SET NUMWIDTH 6
SELECT
    r.usn,      
    r.name,  
    s.osuser, 
    s.username, 
    s.sid,   
    x.extents, 
    x.extends,  
    x.waits, 
    x.shrinks,
    x.wraps
FROM
    sys.v_$rollstat x,
    sys.v_$rollname r,  
    sys.v_$session s,
    sys.v_$transaction t
WHERE
    t.addr = s.taddr (+)
    AND x.usn (+) = r.usn
    AND t.xidusn (+) = r.usn
ORDER BY
    r.usn
/
@_END
