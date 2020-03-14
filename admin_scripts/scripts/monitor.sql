REM
REM  In order for the views used for monitoring to be created
REM  these direct grants have to be made to the user who will be
REM  doing the monitoring. It is suggested that the user
REM  also be granted the DBA role or the MONITORER role.
REM
REM  These grants must be made from the SYS user.
REM

@_BEGIN 
ACCEPT monitoring_user PROMPT "Monitoring user: "
GRANT SELECT ON dba_free_space TO &&monitoring_user;
GRANT SELECT ON v_$rollstat TO &&monitoring_user;
GRANT SELECT ON v_$rollname TO &&monitoring_user;
GRANT SELECT ON v_$sgastat TO &&monitoring_user;
GRANT SELECT ON v_$sqlarea TO &&monitoring_user;
GRANT SELECT ON v_$lock TO &&monitoring_user;
GRANT SELECT ON dba_users TO &&monitoring_user;
GRANT SELECT ON v_$process TO &&monitoring_user;
GRANT SELECT ON dba_source TO &&monitoring_user;
GRANT SELECT ON dba_rollback_segs TO &&monitoring_user;
GRANT SELECT ON v_$rowcache TO &&monitoring_user;
GRANT SELECT ON v_$sysstat TO &&monitoring_user;
GRANT SELECT ON v_$waitstat TO &&monitoring_user;
GRANT SELECT ON v_$instance TO &&monitoring_user;
GRANT SELECT ON v_$librarycache TO &&monitoring_user;
GRANT SELECT ON v_$sga TO &&monitoring_user;
GRANT SELECT ON v_$latchname TO &&monitoring_user;
GRANT SELECT ON v_$latch TO &&monitoring_user;
GRANT SELECT ON dba_tablespaces TO &&monitoring_user;
GRANT SELECT ON dba_indexes TO &&monitoring_user;
GRANT SELECT ON dba_extents TO &&monitoring_user;
GRANT SELECT ON dba_objects TO &&monitoring_user;
GRANT SELECT ON dba_data_files TO &&monitoring_user;
GRANT SELECT ON dba_tables TO &&monitoring_user;
GRANT SELECT ON dba_tab_columns TO &&monitoring_user;
UNDEFINE monitoring_user
@_END
