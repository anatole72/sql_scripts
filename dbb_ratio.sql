
clear breaks
clear computes
clear columns

column pct heading "Hit Ratio (%)" format 999.9

ttitle  'Buffer Cache Checks - Goal, above 95%' skip 2
			
select  ((1- (sum(decode(a.name,'physical reads',value,0)))/
        (sum(decode(a.name,'db block gets',value,0)) +
         sum(decode(a.name,'consistent gets',value,0)))) * 100) "PERCENT"
from    v$sysstat a;
