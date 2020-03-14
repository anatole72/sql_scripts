clear breaks
clear computes
clear columns
	    
ttitle 'Buffer Contention Specific - PARAMETERS PRINTED IF > 0' skip - 

select  class,count
from    v$waitstat
where   class in ('data blocks','segment header',
                  'undo header','undo block');
					  
					  
