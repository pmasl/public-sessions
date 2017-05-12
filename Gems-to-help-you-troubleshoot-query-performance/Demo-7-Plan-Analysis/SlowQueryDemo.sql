USE [AdventureWorks2016CTP3]
GO

IF EXISTS (SELECT [object_id] FROM sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID(N'[Sales].[SalesFromDate]') AND [type] IN (N'P'))
DROP PROCEDURE Sales.SalesFromDate
GO

IF NOT EXISTS (SELECT [object_id] FROM sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID(N'[Sales].[SalesFromDate]') AND [type] IN (N'P'))
EXEC ('CREATE OR ALTER PROCEDURE [Sales].[SalesFromDate] @StartOrderdate datetime 
AS 
SELECT *
FROM Sales.SalesOrderHeaderBulk AS h 
INNER JOIN Sales.SalesOrderDetailBulk AS d ON h.SalesOrderID = d.SalesOrderID
WHERE (h.OrderDate >= @StartOrderdate)')
GO

--Original
ALTER DATABASE [AdventureWorks2016CTP3] SET COMPATIBILITY_LEVEL = 140;
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
EXEC sp_executesql N'exec Sales.SalesFromDate @P1',N'@P1 datetime2(0)','2004-7-31 00:00:00'
EXEC sp_executesql N'exec Sales.SalesFromDate @P1',N'@P1 datetime2(0)','2004-3-28 00:00:00'

--Fix 1 - RECOMPILE
ALTER PROCEDURE Sales.SalesFromDate (@StartOrderdate datetime) AS 
SELECT * FROM Sales.SalesOrderHeaderBulk AS h 
INNER JOIN Sales.SalesOrderDetailBulk AS d ON h.SalesOrderID = d.SalesOrderID 
WHERE (h.OrderDate >= @StartOrderdate) 
OPTION (RECOMPILE)
GO

--Fix 2 - OPTIMIZE FOR
ALTER PROCEDURE Sales.SalesFromDate (@StartOrderdate datetime) AS 
SELECT * FROM Sales.SalesOrderHeaderBulk AS h 
INNER JOIN Sales.SalesOrderDetailBulk AS d ON h.SalesOrderID = d.SalesOrderID 
WHERE (h.OrderDate >= @StartOrderdate) 
--OPTION (OPTIMIZE FOR(@StartOrderDate = 'xxxx'))
OPTION (OPTIMIZE FOR UNKNOWN)
GO

--Fix 3 - local variable
ALTER PROCEDURE Sales.SalesFromDate (@StartOrderdate datetime) AS 
DECLARE @date datetime 
SELECT @date=@StartOrderDate 
SELECT * FROM Sales.SalesOrderHeaderBulk AS h 
INNER JOIN Sales.SalesOrderDetailBulk AS d ON h.SalesOrderID = d.SalesOrderID 
WHERE (h.OrderDate >= @date)
GO


--Reset
ALTER PROCEDURE Sales.SalesFromDate (@StartOrderdate datetime) AS 
SELECT * FROM Sales.SalesOrderHeaderBulk AS h 
INNER JOIN Sales.SalesOrderDetailBulk AS d ON h.SalesOrderID = d.SalesOrderID 
WHERE (h.OrderDate >= @StartOrderdate) 
GO