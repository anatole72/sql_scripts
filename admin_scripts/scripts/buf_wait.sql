PROMPT
PROMPT  The following script lists the number of waits for free buffer to be
PROMPT  made available for new data being brought into the buffer cache. The 
PROMPT  output is often a sign of an untuned DBWR of a buffer cache that is
PROMPT  too small. 
REM     Author: Mark Gurry

@_BEGIN
SELECT 
    name, 
    value
FROM 
    v$sysstat
WHERE 
    name = 'free buffer waits'
;
@_END
