PROMPT
PROMPT The following script lists various statistics to do with table fetches,
PROMPT including the number of chained rows (table fetch continued row), and
PROMPT short and long table full table scans. 

@_BEGIN
@_TITLE "TABLE ACCESS METHODS"

SELECT 
    name, 
    value 
FROM 
    v$sysstat
WHERE  
    name LIKE '%table %'
ORDER BY 
    name
;
@_END
