/*
 * AdvWorksOLTP_query.sql contains the select query to produce the Geographical Penetration and Product Mix - 
 * US Territories Only (For All Time) report. The query uses the view by name of
 * vPostalCodePenetrationAndProductMix to simplify readability. The individual subqueries used to produce
 * the report are also included in this file.
 *
 * Before running these queries, please make sure that AdvWorksOLTP_vPostalCodePenetrationAndProductMix.sql
 * is executed.
 *
 * Author: Andrew Fisher
 * Version: 1.0
 * Last Modified Date: 01/27/2014
 */
 
USE [AdventureWorks2008R2];
GO

--Geographical Penetration and Product Mix - US Territories Only (For All Time) report
SELECT distinctBuyersByPostalCode.[PostalCode]
	  ,distinctBuyersByPostalCode.NumDistinctCustomers AS NumberDistinctBuyers
	  ,avgTransAmtAndTotalRevenueByPostalCode.[AverageTransactionAmount]
	  ,avgTransAmtAndTotalRevenueByPostalCode.[TotalRevenue]
	  ,mostPopularProdCatByPostalCode.[ProductCategory] AS MostPopularProductCategory
FROM (
		SELECT [PostalCode]
			  ,COUNT(DISTINCT [CustomerID]) AS NumDistinctCustomers
		FROM [dbo].[vPostalCodePenetrationAndProductMix]
		GROUP BY [PostalCode]
     ) as distinctBuyersByPostalCode
INNER
JOIN (
		SELECT a.[PostalCode]
			  ,AVG(a.[OrderTotal]) AS AverageTransactionAmount
			  ,SUM(a.[OrderTotal]) AS TotalRevenue
		FROM (
			SELECT DISTINCT [SalesOrderID]
				  ,[PostalCode]
				  ,[OrderTotal]
			FROM [dbo].[vPostalCodePenetrationAndProductMix]
			) a
		GROUP BY a.[PostalCode]
	 ) AS avgTransAmtAndTotalRevenueByPostalCode
ON avgTransAmtAndTotalRevenueByPostalCode.[PostalCode] = distinctBuyersByPostalCode.[PostalCode]
INNER
JOIN (
	SELECT t1.[PostalCode]
		  ,t2.[ProductCategory]
	FROM (
		SELECT [PostalCode]
			  ,MAX(ordQtySumByProdCatPostalCode.NumProductsSold) AS MaxNumProductsSold
		FROM (
			SELECT [PostalCode]
				  ,[ProductCategory]
				  ,SUM([OrderQty]) AS NumProductsSold
			FROM [dbo].[vPostalCodePenetrationAndProductMix]
			GROUP BY [PostalCode]
					,[ProductCategory]
			 ) AS ordQtySumByProdCatPostalCode
		GROUP BY [PostalCode]
		 ) as t1
	INNER JOIN (
		SELECT [PostalCode]
			  ,[ProductCategory]
			  ,SUM([OrderQty]) AS NumProductsSold
		FROM [dbo].[vPostalCodePenetrationAndProductMix]
		GROUP BY [PostalCode]
				,[ProductCategory]
			   ) as t2
	ON t1.[PostalCode] = t2.[PostalCode]
	AND t1.[MaxNumProductsSold] = t2.[NumProductsSold]
) AS mostPopularProdCatByPostalCode
ON mostPopularProdCatByPostalCode.[PostalCode] = distinctBuyersByPostalCode.[PostalCode]
ORDER BY distinctBuyersByPostalCode.[PostalCode] ASC;
GO

--Number of Distinct Buyers by postal code
SELECT [PostalCode]
      ,COUNT(DISTINCT [CustomerID])
FROM [dbo].[vPostalCodePenetrationAndProductMix]
GROUP BY [PostalCode];

--Average Transaction Amount and Total Revenue by postal code
SELECT a.[PostalCode]
      ,AVG(a.[OrderTotal]) AS AverageTransactionAmount
	  ,SUM(a.[OrderTotal]) AS TotalRevenue
FROM (
	SELECT DISTINCT [SalesOrderID]
	      ,[PostalCode]
	      ,[OrderTotal]
	FROM [dbo].[vPostalCodePenetrationAndProductMix]
	) a
GROUP BY a.[PostalCode];

--Most Popular Product Category by postal code
SELECT t1.[PostalCode]
      ,t2.[ProductCategory]
FROM (
	SELECT [PostalCode]
	      ,MAX(ordQtySumByProdCatPostalCode.NumProductsSold) AS MaxNumProductsSold
	FROM (
		SELECT [PostalCode]
		      ,[ProductCategory]
		      ,SUM([OrderQty]) AS NumProductsSold
		FROM [dbo].[vPostalCodePenetrationAndProductMix]
		GROUP BY [PostalCode]
			    ,[ProductCategory]
		 ) AS ordQtySumByProdCatPostalCode
	GROUP BY [PostalCode]
	 ) as t1
INNER JOIN (
	SELECT [PostalCode]
		  ,[ProductCategory]
		  ,SUM([OrderQty]) AS NumProductsSold
	FROM [dbo].[vPostalCodePenetrationAndProductMix]
	GROUP BY [PostalCode]
			,[ProductCategory]
		   ) as t2
ON t1.[PostalCode] = t2.[PostalCode]
AND t1.[MaxNumProductsSold] = t2.[NumProductsSold];