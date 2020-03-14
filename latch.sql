

clear breaks
clear computes
clear columns

column name heading "Latch Type" format a25
column pct_miss heading "Misses/Gets (%)" format 999.99999
column pct_immed heading "Immediate Misses/Gets (%)" format 999.99999

ttitle  'Latch Contention Analysis Report' skip 2
      
select  n.name,
        misses*100/(gets+1) pct_miss,
        immediate_misses*100/(immediate_gets+1) pct_immed
from v$latchname n,v$latch l
where   n.latch# = l.latch#
 and    n.name in('%cache bugffer%','%protect%');
