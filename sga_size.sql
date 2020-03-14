

ttitle 'COMPUTE SUM OF VALUE kbval ON REPORT' skip 2

clear breaks
clear computes
clear columns

column name     format a20 heading "SGA Segment"
column value    format 999,999,999,990  heading "Size|(Bytes)"
column kbval    format 999,999,990.9 heading "Size|(Kb)"
break on report

select  name,value,round(value/1024,1) kbval
 from v$sga;
