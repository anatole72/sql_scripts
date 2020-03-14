REM
REM  This script lists who is holding which latches.
REM  Author: Mark Gurry
REM

@_BEGIN
@_TITLE 'Latch Holders'
SELECT 
    l.name "Latch Held", 
    p.username "User Holding Latch"
FROM 
    v$process p,
    v$latchholder l
WHERE 
    l.pid  = p.pid
;
@_END
