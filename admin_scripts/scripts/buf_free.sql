REM
REM  Database buffer cache free and used blocks
REM

@_BEGIN
@_TITLE "BUFFER CACHE FREE AND USED BLOCKS"
COLUMN status FORMAT A6

SELECT 
    DECODE(status, 'FREE', 'Free', 'Used') Status, 
    COUNT(*) Buffers
FROM
    v$bh 
GROUP BY 
    DECODE(status, 'FREE', 'Free', 'Used')
/
@_END
	
