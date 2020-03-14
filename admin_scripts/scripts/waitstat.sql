@_BEGIN
@_TITLE "WAITS STATISTICS"
SELECT 
    class, 
    count,
    time,
    DECODE(class,
        'undo header', DECODE(count, 0, '', 'Add rollback segments?'),
        'undo block', DECODE(count, 0, '', 'Add rollback segments?'),
        'system undo header', DECODE(count, 0, '', 'Add rollback segments?'),
        'system undo block', DECODE(count, 0, '', 'Add rollback segments?'),
        'free list', DECODE(count, 0, '', 'Make more freelists?')
    ) recommendation
FROM 
    v$waitstat
ORDER BY
    class
;
@_END
