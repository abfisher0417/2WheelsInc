/*
 * AdvWorksOLTP_vPostalCodePenetrationAndProductMix.sql creates the "vPostalCodePenetrationAndProductMix" view.
 * The view is leveraged to produce the Geographical Penetration and Product Mix - US Territories Only (For All
 * Time) report.
 *
 * Author: Andrew Fisher
 * Version: 1.0
 * Last Modified Date: 01/28/2014
 */

USE [AdventureWorks2008R2];
GO

IF OBJECT_ID ('vPostalCodePenetrationAndProductMix', 'V') IS NOT NULL
	DROP VIEW vPostalCodePenetrationAndProductMix;
GO

CREATE VIEW vPostalCodePenetrationAndProductMix
AS
--SELECT SQL below fetches a consolidated view of data from necessary tables to produce
--the Geographical Penetration and Product Mix - US Territories Only (For All Time)
--report for retail/wholesale sales. This query is UNION'd with a SELECT SQL that does
--the same for Internet sales.
SELECT salesOrdHdr.[SalesOrderID]
	,salesOrdHdr.[CustomerID]
	,salesOrdHdr.[OnlineOrderFlag]
	,salesOrdHdr.[SubTotal] AS OrderTotal
	--,salesOrdHdr.[TotalDue] AS OrderTotal
	,cust.[PersonID]
	,cust.[StoreID]
	,addrType.[Name] AS AddressType
	,addr.[City]
	,stProv.[Name] AS StateName
	,addr.[PostalCode]
	,salesOrdDet.[OrderQty]
	,prodCat.[Name] AS ProductCategory
FROM [Sales].[SalesOrderHeader] salesOrdHdr
INNER JOIN [Sales].[Customer] AS cust
	ON  cust.[CustomerID] = salesOrdHdr.[CustomerID]
INNER JOIN [Person].[BusinessEntity] AS busEntity
	ON  busEntity.[BusinessEntityID] = cust.[StoreID]
INNER JOIN [Person].[BusinessEntityAddress] AS busEntityAddr
	ON busEntityAddr.[BusinessEntityID] = busEntity.[BusinessEntityID]
INNER JOIN [Person].[Address] AS addr
	ON addr.[AddressID] = busEntityAddr.[AddressID]
INNER JOIN [Person].[StateProvince] AS stProv
	ON stProv.[StateProvinceID] = addr.[StateProvinceID]
INNER JOIN [Person].[AddressType] AS addrType
	ON addrType.[AddressTypeID] = busEntityAddr.[AddressTypeID]
INNER JOIN [Sales].[SalesOrderDetail] AS salesOrdDet
	ON salesOrdDet.[SalesOrderID] = salesOrdHdr.[SalesOrderID]
INNER JOIN [Production].[Product] AS prod
	ON prod.[ProductID] = salesOrdDet.[ProductID]
INNER JOIN [Production].[ProductSubcategory] AS prodSubCat
	ON prodSubCat.ProductSubcategoryID = prod.[ProductSubcategoryID]
INNER JOIN [Production].[ProductCategory] AS prodCat
	ON prodCat.[ProductCategoryID] = prodSubCat.[ProductCategoryID]
WHERE salesOrdHdr.[TerritoryID] IN (--Include sales records for US territories only.
	SELECT [TerritoryID]
	FROM [Sales].[SalesTerritory]
	WHERE [CountryRegionCode] = 'US'
)
AND salesOrdHdr.[Status] IN (5)			--Include orders that were shipped. Exclude other statuses. Order statuses are:
										--1 = In process, 2 = Approved, 3 = Back ordered, 4 = Rejected, 5 = Shipped, 6 = Cancelled
AND cust.[StoreID] IS NOT NULL			--Order placed by sales person and purchased by retail/wholesale store.
AND cust.[PersonID] IS NOT NULL
AND salesOrdHdr.[OnlineOrderFlag] = 0	--Order placed by sales person.
AND addrType.[Name] = 'Main Office'		--Each store has a Main Office address.
UNION ALL
SELECT salesOrdHdr.[SalesOrderID]
	,salesOrdHdr.[CustomerID]
	,salesOrdHdr.[OnlineOrderFlag]
	,salesOrdHdr.[SubTotal] AS OrderTotal
	--,salesOrdHdr.[TotalDue] AS OrderTotal
	,cust.[PersonID]
	,cust.[StoreID]
	,addrType.[Name] AS AddressType
	,addr.[City]
	,stProv.[Name] AS StateName
	,addr.[PostalCode]
	,salesOrdDet.[OrderQty]
	,prodCat.[Name] AS ProductCategory
FROM [Sales].[SalesOrderHeader] salesOrdHdr
INNER JOIN [Sales].[Customer] AS cust
	ON  cust.[CustomerID] = salesOrdHdr.[CustomerID]
INNER JOIN [Person].[BusinessEntity] AS busEntity
	ON  busEntity.[BusinessEntityID] = cust.[PersonID]
INNER JOIN [Person].[BusinessEntityAddress] AS busEntityAddr
	ON busEntityAddr.[BusinessEntityID] = busEntity.[BusinessEntityID]
INNER JOIN [Person].[Address] AS addr
	ON addr.[AddressID] = busEntityAddr.[AddressID]
INNER JOIN [Person].[StateProvince] AS stProv
	ON stProv.[StateProvinceID] = addr.[StateProvinceID]
INNER JOIN [Person].[AddressType] AS addrType
	ON addrType.[AddressTypeID] = busEntityAddr.[AddressTypeID]
INNER JOIN [Sales].[SalesOrderDetail] AS salesOrdDet
	ON salesOrdDet.[SalesOrderID] = salesOrdHdr.[SalesOrderID]
INNER JOIN [Production].[Product] AS prod
	ON prod.[ProductID] = salesOrdDet.[ProductID]
INNER JOIN [Production].[ProductSubcategory] AS prodSubCat
	ON prodSubCat.ProductSubcategoryID = prod.[ProductSubcategoryID]
INNER JOIN [Production].[ProductCategory] AS prodCat
	ON prodCat.[ProductCategoryID] = prodSubCat.[ProductCategoryID]
WHERE salesOrdHdr.[TerritoryID] IN (--Include sales records for US territories only.
	SELECT [TerritoryID]
	FROM [Sales].[SalesTerritory]
	WHERE [CountryRegionCode] = 'US'
)
AND salesOrdHdr.[Status] IN (5)			--Include orders that were shipped. Exclude other statuses. Order statuses are:
										--1 = In process, 2 = Approved, 3 = Back ordered, 4 = Rejected, 5 = Shipped, 6 = Cancelled
AND cust.[StoreID] IS NULL				--Order placed by buyer directly on Internet.
AND cust.[PersonID] IS NOT NULL
AND salesOrdHdr.[OnlineOrderFlag] = 1	--Order placed online by customer.
AND addrType.[Name] = 'Home';			--Every individual has a Home address.
GO