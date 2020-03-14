REM
REM  Hit Ratio by user
REM

@_BEGIN
@_TITLE "HIT RATIO BY USERS"
COLUMN "Hit_Ratio_%" FORMAT 999.99

SELECT
   username, 
   consistent_gets consist_gets, 
   block_gets, 
   physical_reads physic_reads, 
   100 * (consistent_gets + block_gets - physical_reads) /
         (consistent_gets + block_gets) "HIT_RATIO_%" 
FROM
   v$session,
   v$sess_io
WHERE
   v$session.sid = v$sess_io.sid
   AND (consistent_gets + block_gets) > 0
   AND username IS NOT NULL
ORDER BY
   username
;

@_END
