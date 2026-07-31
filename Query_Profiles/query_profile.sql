select * from SNOWFLAKE.ACCOUNT_USAGE.QUERY_INSIGHTS;


SELECT 
    query_id,
    user_name,
    warehouse_name,
    execution_status,
    round(total_elapsed_time / 1000, 2) AS total_duration_sec,
    round(queued_provisioning_time / 1000, 2) AS provisioning_queue_sec,
    round(queued_overload_time / 1000, 2) AS warehouse_queue_sec,
    query_text
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY_BY_WAREHOUSE(
    WAREHOUSE_NAME => CURRENT_WAREHOUSE(),
    END_TIME_RANGE_START => DATEADD('minute', -30, CURRENT_TIMESTAMP())
))
WHERE execution_status IN ('RUNNING', 'QUEUED')
ORDER BY total_elapsed_time DESC;


SELECT 
    query_id,
    user_name,
    warehouse_name,
    warehouse_size,
    round(total_elapsed_time / 1000 / 60, 2) AS total_minutes,
    bytes_spilled_to_local_storage / (1024*1024*1024) AS local_spill_gb,
    bytes_spilled_to_remote_storage / (1024*1024*1024) AS remote_spill_gb,
    query_text
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
  AND (bytes_spilled_to_local_storage > 0 OR bytes_spilled_to_remote_storage > 0)
ORDER BY bytes_spilled_to_remote_storage DESC, bytes_spilled_to_local_storage DESC
LIMIT 20;


SELECT 
    i.query_id,
    q.user_name,
    q.warehouse_name,
    i.insight_type_id,
    i.message,
    q.query_text
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_INSIGHTS i
JOIN SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY q
  ON i.query_id = q.query_id
WHERE q.start_time >= DATEADD('day', -3, CURRENT_TIMESTAMP())
ORDER BY q.start_time DESC
LIMIT 50;



SELECT 
    query_id,
    user_name,
    warehouse_name,
    partitions_scanned,
    partitions_total,
    round((partitions_scanned / NULLIF(partitions_total, 0)) * 100, 2) AS pct_scanned,
    bytes_scanned / (1024*1024*1024) AS gb_scanned,
    query_text
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
  AND partitions_total > 100
  AND (partitions_scanned / partitions_total) > 0.80 -- Scanned over 80% of partitions
ORDER BY bytes_scanned DESC
LIMIT 20;
