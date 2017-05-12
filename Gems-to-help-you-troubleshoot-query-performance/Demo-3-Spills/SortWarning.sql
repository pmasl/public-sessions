-- Sort Spill

-- Create xEvent session
DROP EVENT SESSION [SortSpills] ON SERVER 
GO
CREATE EVENT SESSION [SortSpills] ON SERVER 
ADD EVENT sqlserver.sort_warning(
    ACTION(sqlserver.database_name,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_hash_signed,sqlserver.query_plan_hash,sqlserver.query_plan_hash_signed,sqlserver.session_nt_username,sqlserver.sql_text))
ADD TARGET package0.event_file(SET filename=N'C:\IP\Tiger\Gems to help you troubleshoot query performance\Demos\Demo 3 - Spills\SortSpills.xel',max_file_size=(50),max_rollover_files=(2))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

USE AdventureWorks2014
--USE AdventureWorks2016CTP3
GO 
--Execute  
DBCC FREEPROCCACHE
GO
ALTER EVENT SESSION [SortSpills] ON SERVER STATE = START
GO
SELECT *
FROM Sales.SalesOrderDetail SOD
INNER JOIN Production.Product P ON SOD.ProductID = P.ProductID
ORDER BY Style
OPTION (QUERYTRACEON 9481)
GO
ALTER EVENT SESSION [SortSpills] ON SERVER STATE = STOP
GO

/*
Observe the type of Spill = 1
Means one pass over the data was enough to complete the sort in the Worktable
*/

/*
Shows list of active trace flags: Session and Global
*/

-- also repeat with set statistics io on, to show sort's worktable statistics