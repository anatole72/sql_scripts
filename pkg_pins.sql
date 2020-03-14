
clear breaks
clear computes
clear columns

ttitle 'Packages in dba_object_size NOT owned by SYS or SYSTEM' skip 2
 
column total_bytes format 9999999 heading 'Total|Bytes'
column "OBJECT" format A25
column type format A15

select    owner || '.' || name OBJECT,
          type, 
          to_char(sharable_mem/1024,'9,999.9') "SPACE(K)",
          loads, 
	  executions execs,
	  kept
from v$db_object_cache
 where 
       type in ('FUNCTION','PACKAGE','PACKAGE BODY','PROCEDURE')
  and  owner not in ('SYS','SYSTEM')
  and  kept = 'NO'
  and  sharable_mem > 100000
  order by owner, name;
			
			
