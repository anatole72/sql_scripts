

clear breaks
clear computes
clear columns

ttitle 'REDO CONTENTION REPORT' skip

column value format 999,999,999  

select substr(name,1,30) Name,  
       value  
from   v$sysstat 
where  name = 'redo log space requests';

