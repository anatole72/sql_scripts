
clear breaks
clear computes
clear columns
  
set pagesize 18

ttitle 'GET WAIT RATIO ROLLBACK REPORT' 

column "Ratio" format 999.99999999 
column  name format A15
--column "PERCENT" 

select  name, 
        waits, 
        gets, 
        100-(waits/gets) "Ratio",
        (waits/gets)*100 "PERCENT"
 from v$rollstat a, v$rollname b  
where a.usn = b.usn;  
			       

clear breaks
clear computes
clear columns
ttitle 'ROLLBACK GENERAL INFORMATION' skip 2
select   rssize,
         optsize,
         hwmsize,
         shrinks,
         wraps,  
         extends,
         aveactive  
from   v$rollstat  
order  by rownum;
					       
					       

