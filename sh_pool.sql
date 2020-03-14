clear breaks
clear computes
clear columns
	    
ttitle 'FREE MEMORY IN SHARED POOL REPORT' skip 2

select name, 
       (bytes/1024/1024) "Free Memory in MB" 
from v$sgastat
where  name = 'free memory';


clear breaks
clear computes
clear columns
column name format A25

ttitle 'OBJECTS IN CACHE REPORT' skip

select name,
       sharable_mem "Memory in bytes"
from v$db_object_cache 
where sharable_mem > 10000
  and type in ('PACKAGE','PACKAGE BODY','FUNCTION','PROCEDURE');
  

clear breaks
clear computes
clear columns

ttitle 'RELOADS-library cache misses' skip 2

column libcache format 99.99 heading 'Library Cache Miss Ratio (%) <1%'

select  sum(pins) "Executions",
        sum(reloads) "Reloads While Executing",
        sum(reloads)/sum(pins) *100 libcache
from v$librarycache;
					
					
