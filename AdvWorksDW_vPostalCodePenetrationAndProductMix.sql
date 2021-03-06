/*
 * AdvWorksDW_vPostalCodePenetrationAndProductMix.sql creates the "vPostalCodePenetrationAndProductMix" view.
 * The view is leveraged to produce the Geographical Penetration and Product Mix - US Territories Only (For All
 * Time) report.
 *
 * Author: Andrew Fisher
 * Version: 1.0
 * Last Modified Date: 01/28/2014
 */

USE [AdventureWorksDW2008R2];
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
SELECT resellerSale.[SalesOrderNumber]
      ,resellerSale.[ResellerKey] AS CustomerID
	  ,resellerSale.[SalesAmount] AS ProductTotal
      --,(resellerSale.[SalesAmount] + resellerSale.[TaxAmt] + resellerSale.[Freight]) AS ProductTotal
      ,geo.[City]
      ,geo.[StateProvinceName] AS StateName
      ,geo.[PostalCode]
	  ,resellerSale.[OrderQuantity] AS ProductQty
	  ,productCat.[EnglishProductCategoryName] AS ProductCategory
FROM [dbo].[FactResellerSales] AS resellerSale
INNER JOIN [dbo].[DimSalesTerritory]	AS salesTerritory	
	ON salesTerritory.[SalesTerritoryKey] = resellerSale.[SalesTerritoryKey]
	AND salesTerritory.[SalesTerritoryCountry] = 'United States'	--Include sales records for US territories only.
INNER JOIN [dbo].[DimReseller] AS reseller
	ON resellerSale.[ResellerKey] = reseller.[ResellerKey]
INNER JOIN [AdventureWorksDW2008R2].[dbo].[DimGeography] AS geo
	ON geo.[GeographyKey] = reseller.[GeographyKey]
INNER JOIN [dbo].[DimProduct] AS product
	ON product.[ProductKey] = resellerSale.[ProductKey]
LEFT JOIN [dbo].[DimProductSubcategory] AS productSubCat
	ON productSubCat.[ProductSubcategoryKey] = product.[ProductSubcategoryKey]
LEFT JOIN [dbo].[DimProductCategory] AS productCat
	ON productCat.[ProductCategoryKey] = productSubCat.[ProductCategoryKey]
UNION ALL
SELECT internetSale.[SalesOrderNumber]
      ,internetSale.[CustomerKey] AS CustomerID
	  ,internetSale.[SalesAmount] AS ProductTotal
      --,(resellerSale.[SalesAmount] + resellerSale.[TaxAmt] + resellerSale.[Freight]) AS ProductTotal
      ,geo.[City]
      ,geo.[StateProvinceName] AS StateName
      ,geo.[PostalCode]
	  ,internetSale.[OrderQuantity] AS ProductQty
	  ,productCat.[EnglishProductCategoryName] AS ProductCategory
FROM [dbo].[FactInternetSales] AS internetSale
INNER JOIN [dbo].[DimSalesTerritory]	AS salesTerritory	
	ON salesTerritory.[SalesTerritoryKey] = internetSale.[SalesTerritoryKey]
	AND salesTerritory.[SalesTerritoryCountry] = 'United States'		--Include sales records for US territories only.
INNER JOIN [dbo].[DimCustomer] AS cust
	ON internetSale.[CustomerKey] = cust.[CustomerKey]
INNER JOIN [AdventureWorksDW2008R2].[dbo].[DimGeography] AS geo
	ON geo.[GeographyKey] = cust.[GeographyKey]
INNER JOIN [dbo].[DimProduct] AS product
	ON product.[ProductKey] = internetSale.[ProductKey]
LEFT JOIN [dbo].[DimProductSubcategory] AS productSubCat
	ON productSubCat.[ProductSubcategoryKey] = product.[ProductSubcategoryKey]
LEFT JOIN [dbo].[DimProductCategory] AS productCat
	ON productCat.[ProductCategoryKey] = productSubCat.[ProductCategoryKey];
GO