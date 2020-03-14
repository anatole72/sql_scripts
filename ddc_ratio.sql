
ttitle 'DATA DICTIONARY CACHE RATIO REPORT <5%' skip 2

clear breaks
clear computes
clear columns

column "Data Dict. Gets"   format 999,999,999  
column "Data Dict. cache misses" format 999,999,999
column dictcache format 999.99 heading 'Dictionary Cache Ratio %'  

select   sum(gets) "Data Dict. Gets",  
         sum(getmisses) "Data Dict. cache misses",  
         sum(getmisses)/(sum(gets)+0.00000000001) * 100 dictcache  
from v$rowcache;
