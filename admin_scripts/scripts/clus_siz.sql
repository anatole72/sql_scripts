REM
REM  Generate a cluster sizing report
REM

@_BEGIN
@_WTITLE "Cluster Sizing Report"

COLUMN clus_name    	FORMAT A28     		HEADING "Cluster"
COLUMN tablespace_name 	FORMAT A16     		HEADING "Tablespace"
COLUMN pct_free        	FORMAT 999999    	HEADING "% Free"
COLUMN pct_used        	FORMAT 999999    	HEADING "% Used"
COLUMN key_size        	FORMAT 999999    	HEADING "Key Size"
COLUMN ini_trans       	FORMAT 999     		HEADING "IT"
COLUMN max_trans       	FORMAT 999999    	HEADING "Max Tran"
COLUMN initial_extent  	FORMAT 999999999 	HEADING "Initial Ext"
COLUMN next_extent     	FORMAT 999999999	HEADING "Next Ext"
COLUMN min_extents     	FORMAT 9999    		HEADING "Min Exts"
COLUMN max_extents     	FORMAT 9999    		HEADING "Max Exts"
COLUMN pct_increase    	FORMAT 9999    		HEADING "% Inc"
BREAK ON owner 

SELECT 
    owner || '.' ||
    cluster_name clus_name,
    tablespace_name,
    pct_free,
    pct_used,
    key_size,	
    ini_trans,
    max_trans,
    initial_extent, 
    next_extent, 
    min_extents, 
    max_extents,
    pct_increase
FROM 
    dba_clusters
ORDER BY 
    1, 2
/
@_END

