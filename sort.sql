
clear breaks
clear computes
clear columns


ttitle 'Sorts Disk/Memory' skip 2
		   
select  substr(name,1,30) "Statistic Name",
        value
from v$sysstat
where  name in ('sorts (memory)','sorts (disk)');
