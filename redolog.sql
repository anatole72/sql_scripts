

clear breaks
clear computes
clear columns

col f1 format a55 heading 'Redo Log File Name'
col f2 format 9999 heading 'Group'
col f3 format a10 heading 'Status'

ttitle  'Redo Log File Names Report' skip 

break on f2 skip

select  GROUP# f2,
        STATUS f3,
        MEMBER f1
from    v$logfile
order by GROUP#,MEMBER;


--
--  Redo Content info
--
clear breaks
clear computes
clear columns

ttitle 'REDO CONTENTION REPORT' skip

column value format 999,999,999  

select substr(name,1,30) Name,  
       value  
from   v$sysstat 
where  name = 'redo log space requests';

