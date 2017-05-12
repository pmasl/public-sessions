IF DB_NAME() != 'AdventureWorks2016CTP3' 
USE AdventureWorks2016CTP3
SET NOCOUNT ON
GO

/*
IF EXISTS (SELECT [object_id] FROM sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID(N'[Sales].[SalesOrderHeaderBulk]') AND [type] IN (N'U'))
DROP TABLE [Sales].[SalesOrderHeaderBulk];
GO
*/

IF NOT EXISTS (SELECT [object_id] FROM sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID(N'[Sales].[SalesOrderHeaderBulk]') AND [type] IN (N'U'))
CREATE TABLE [Sales].[SalesOrderHeaderBulk](
	[SalesOrderID] [INT] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RevisionNumber] [tinyint] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[DueDate] [datetime] NOT NULL,
	[ShipDate] [datetime] NULL,
	[Status] [tinyint] NOT NULL,
	[CustomerID] [INT] NOT NULL,
	[ContactID] [INT] NULL,
	[SalesPersonID] [INT] NULL,
	[TerritoryID] [INT] NULL,
	[BillToAddressID] [INT] NOT NULL,
	[ShipToAddressID] [INT] NOT NULL,
	[ShipMethodID] [INT] NOT NULL,
	[CreditCardID] [INT] NULL,
	[CreditCardApprovalCode] [varchar](15) NULL,
	[CurrencyRateID] [INT] NULL,
	[SubTotal] [money] NOT NULL,
	[TaxAmt] [money] NOT NULL,
	[Freight] [money] NOT NULL,
	[TotalDue] AS (ISNULL(([SubTotal]+[TaxAmt])+[Freight],(0))),
	[Comment] [nvarchar](128) NULL,
	[ModifiedDate] [datetime2] NOT NULL,
	CONSTRAINT [PK_SalesOrderHeaderBulk_SalesOrderID] PRIMARY KEY CLUSTERED 
		(
			[SalesOrderID] ASC, 
			[ModifiedDate] ASC
		)
)
GO

/*
IF EXISTS (SELECT [object_id] FROM sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID(N'[Sales].[SalesOrderDetailBulk]') AND [type] IN (N'U'))
DROP TABLE [Sales].[SalesOrderDetailBulk];
GO
*/

IF NOT EXISTS (SELECT [object_id] FROM sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID(N'[Sales].[SalesOrderDetailBulk]') AND [type] IN (N'U'))
CREATE TABLE [Sales].[SalesOrderDetailBulk](
	[SalesOrderID] [INT] NOT NULL,
	[SalesOrderDetailID] [INT] IDENTITY(1,1) NOT NULL,
	[CarrierTrackingNumber] [nvarchar](25) NULL,
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [INT] NOT NULL,
	[SpecialOfferID] [INT] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[UnitPriceDiscount] [money] NOT NULL,
	[LineTotal]  AS (isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0))),
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime2] NOT NULL,
	CONSTRAINT [PK_SalesOrderDetailBulk_SalesOrderID_SalesOrderDetailID] PRIMARY KEY CLUSTERED 
		(
			[SalesOrderID] ASC,
			[SalesOrderDetailID] ASC, 
			[ModifiedDate] ASC
		)
)
GO

-- Populate Tables
IF (SELECT COUNT(*) FROM Sales.SalesOrderHeaderBulk) < 1573250 AND (SELECT COUNT(*) FROM Sales.SalesOrderDetailBulk) < 6065850
BEGIN
	TRUNCATE TABLE Sales.SalesOrderHeaderBulk;
	TRUNCATE TABLE Sales.SalesOrderDetailBulk;

	DECLARE @i smallint
	SET @i = 0
	WHILE @i < 50
	BEGIN
		INSERT INTO Sales.SalesOrderHeaderBulk (RevisionNumber, OrderDate, DueDate, ShipDate, Status, CustomerID, ContactID, SalesPersonID, TerritoryID, BillToAddressID, 
		ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight, Comment, ModifiedDate)
		SELECT RevisionNumber, OrderDate, DueDate, ShipDate, Status, CustomerID, NULL, SalesPersonID, TerritoryID, BillToAddressID, 
			ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight, Comment, ModifiedDate
		FROM Sales.SalesOrderHeader;

		INSERT INTO Sales.SalesOrderDetailBulk (SalesOrderID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate)
		SELECT SalesOrderID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate
		FROM Sales.SalesOrderDetail;
	
		SET @i = @i +1
	END;
END
GO
