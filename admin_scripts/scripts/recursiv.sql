PROMPT
PROMPT The following script lists the number of recursive calls that this 
PROMPT instance has performed. A major cause of recursive calls is having 
PROMPT excessive fragmentation in your database objects. 

@_BEGIN
SELECT 
    SUBSTR (name, 1, 20) name,
    value 
FROM 
    v$sysstat
WHERE 
    name = 'recursive calls'
;
@_END
