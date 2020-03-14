
clear breaks
clear computes
clear columns

ttitle 'High water marks report' skip 2
col event format a37 heading 'Event'  
col total_waits format 99999999 heading 'Total|Waits'
col time_waited format 9999999999 heading 'Time Wait|In Hndrds'  
col total_timeouts format 999999 heading 'Timeout'  
col average_wait heading 'Average|Time' format 999999.999  

select * from v$system_event; 
