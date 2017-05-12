USE AdventureWorks2016CTP3
GO
CREATE INDEX [IX_ProductID] ON [Sales].[SalesOrderDetailBulk] ([ProductID])
INCLUDE ([SalesOrderDetailID],[OrderQty],[UnitPrice],[UnitPriceDiscount],[ModifiedDate])
GO