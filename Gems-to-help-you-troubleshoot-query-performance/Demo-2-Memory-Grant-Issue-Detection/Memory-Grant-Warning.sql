--Execute for warning
USE [memgrants]
GO
DBCC FREEPROCCACHE
GO
SELECT o.col3, o.col2, d.col2
FROM orders o
JOIN orders_detail d ON o.col2 = d.col1
WHERE o.col3 <= 8000
OPTION (LOOP JOIN, MAXDOP 2, MIN_GRANT_PERCENT = 20)
GO

/*
In SELECT node properties:
MaxQueryMemory for maximum query memory grant under RG MAX_MEMORY_PERCENT hint
MaxCompileMemory for maximum query optimizer memory in KB during compile under RG
*/


-- Create xEvent session in 2016
-- Detect inaccurate or insufficient memory grant, when grant is >5MB as minimum
DROP EVENT SESSION [MemoryGrantXE] ON SERVER
GO
CREATE EVENT SESSION [MemoryGrantXE] ON SERVER 
/*
ADD EVENT sqlserver.query_memory_grant_blocking(
    ACTION(sqlserver.database_name,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_hash_signed,sqlserver.query_plan_hash,sqlserver.query_plan_hash_signed,sqlserver.session_nt_username,sqlserver.sql_text)),
ADD EVENT sqlserver.query_memory_grant_resource_semaphores(
    ACTION(sqlserver.database_name,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_hash_signed,sqlserver.query_plan_hash,sqlserver.query_plan_hash_signed,sqlserver.session_nt_username,sqlserver.sql_text)),
ADD EVENT sqlserver.query_memory_grants(
    ACTION(sqlserver.database_name,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_hash_signed,sqlserver.query_plan_hash,sqlserver.query_plan_hash_signed,sqlserver.session_nt_username,sqlserver.sql_text)),
*/
ADD EVENT sqlserver.query_memory_grant_usage(
    ACTION(sqlserver.database_name,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_hash_signed,sqlserver.query_plan_hash,sqlserver.query_plan_hash_signed,sqlserver.session_nt_username,sqlserver.sql_text))
ADD TARGET package0.event_file(SET filename=N'C:\IP\Tiger\Gems to help you troubleshoot query performance\Demos\Demo 2 - Memory Grant Issue Detection\MemoryGrant.xel',max_file_size=(20))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

USE [memgrants]
GO

--Execute
DBCC FREEPROCCACHE
GO
ALTER EVENT SESSION [MemoryGrantXE] ON SERVER STATE = START
GO
SELECT o.col3, o.col2, d.col2
FROM orders o
JOIN orders_detail d ON o.col2 = d.col1
WHERE o.col3 <= 8000
OPTION (LOOP JOIN, MAXDOP 1, MIN_GRANT_PERCENT = 20)
GO
ALTER EVENT SESSION [MemoryGrantXE] ON SERVER STATE = STOP
GO