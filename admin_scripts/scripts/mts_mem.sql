@_BEGIN

PROMPT  The following script lists how much session memory is being used by 
PROMPT  Multi-threaded server in the shared pool.

SELECT sn.name, SUM(ss.value) total
FROM v$sesstat ss, v$statname sn
WHERE sn.statistic# = ss.statistic# 
AND sn.name = 'session uga memory'
GROUP BY sn.name
/
PROMPT
PROMPT  The result indicates the memory currently allocated to all sessions. 
PROMPT  You can use this figure to increase the shared pool size if you are 
PROMPT  planning to use the multi-threaded server. You can also obtain the 
PROMPT  maximum amount of memory that the server sessions have utilised using 
PROMPT  the following script.

SELECT sn.name, SUM(ss.value) total
FROM v$sesstat ss, v$statname sn
WHERE sn.statistic# = ss.statistic# 
AND sn.name = 'session uga memory max'
GROUP BY sn.name
/

PROMPT
PROMPT  It is usually best to use the latter calculation and add on a 30% 
PROMPT  contingency.

@_END
