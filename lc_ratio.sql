
clear breaks
clear computes
clear columns

set hea off

column sum_pins format 999,999,999  
column sum_reloads format 999,999,999  
column hit_ratio format 999.99999

ttitle 'PINS and Library Cache' skip 2

select 'PINS - # of times an item in the library cache was executed - '||
       sum(pins) sum_pins, 
       'RELOADS - # of library cache misses on execution steps - '||
       sum(reloads) sum_reloads,  
       'Pin hit ratio should be close to 1.0  - '||
       ROUND((sum(reloads)/sum(pins)),6) hit_ratio
from v$librarycache;  
set hea on						
						
