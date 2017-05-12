USE AdventureWorks2016CTP3
GO
SELECT e.[BusinessEntityID], 
       p.[Title], 
       p.[FirstName], 
       p.[MiddleName], 
       p.[LastName], 
       p.[Suffix], 
       e.[JobTitle], 
       pp.[PhoneNumber], 
       pnt.[Name] AS [PhoneNumberType], 
       ea.[EmailAddress], 
       p.[EmailPromotion], 
       a.[AddressLine1], 
       a.[AddressLine2], 
       a.[City], 
       sp.[Name] AS [StateProvinceName], 
       a.[PostalCode], 
       cr.[Name] AS [CountryRegionName], 
       p.[AdditionalContactInfo] 
FROM   [HumanResources].[Employee] AS e 
       INNER JOIN [Person].[Person] AS p 
       ON RTRIM(LTRIM(p.[BusinessEntityID])) = RTRIM(LTRIM(e.[BusinessEntityID])) 
       INNER JOIN [Person].[BusinessEntityAddress] AS bea 
       ON RTRIM(LTRIM(bea.[BusinessEntityID])) = RTRIM(LTRIM(e.[BusinessEntityID])) 
       INNER JOIN [Person].[Address] AS a 
       ON RTRIM(LTRIM(a.[AddressID])) = RTRIM(LTRIM(bea.[AddressID])) 
       INNER JOIN [Person].[StateProvince] AS sp 
       ON RTRIM(LTRIM(sp.[StateProvinceID])) = RTRIM(LTRIM(a.[StateProvinceID])) 
       INNER JOIN [Person].[CountryRegion] AS cr 
       ON RTRIM(LTRIM(cr.[CountryRegionCode])) = RTRIM(LTRIM(sp.[CountryRegionCode])) 
       LEFT OUTER JOIN [Person].[PersonPhone] AS pp 
       ON RTRIM(LTRIM(pp.BusinessEntityID)) = RTRIM(LTRIM(p.[BusinessEntityID])) 
       LEFT OUTER JOIN [Person].[PhoneNumberType] AS pnt 
       ON RTRIM(LTRIM(pp.[PhoneNumberTypeID])) = RTRIM(LTRIM(pnt.[PhoneNumberTypeID])) 
       LEFT OUTER JOIN [Person].[EmailAddress] AS ea 
       ON RTRIM(LTRIM(p.[BusinessEntityID])) = RTRIM(LTRIM(ea.[BusinessEntityID]))
OPTION (QUERYTRACEON 9481)
GO