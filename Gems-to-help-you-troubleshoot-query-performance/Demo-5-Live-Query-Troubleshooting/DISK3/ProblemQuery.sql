USE AdventureWorks2016CTP3
GO
SELECT [SalesOrderDetailID]
      ,[OrderQty]
      ,[UnitPrice]
      ,[UnitPriceDiscount]
      ,[ModifiedDate]
FROM [Sales].[SalesOrderDetailBulk]
WHERE [ProductID] > 710 AND [ProductID] < 999
OPTION (RECOMPILE)
GO