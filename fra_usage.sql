set lines 200
col name for a60
col space_limit for 999999999999999
col space_used  for 999999999999999
SELECT NAME,ROUND(SPACE_LIMIT/1048676/1024,1) "SPACE_LIMIT(GB)",ROUND(SPACE_USED/1048676/1024,1) "SPACE_USED(GB)",ROUND(SPACE_RECLAIMABLE/1048676/1024,1) "SPACE_RECLAIMABLE(GB)" FROM V$RECOVERY_FILE_DEST;
select * from v$recovery_area_usage;
