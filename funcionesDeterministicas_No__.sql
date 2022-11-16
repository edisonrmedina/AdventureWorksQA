select DISTINCT(region) from (select ProductInventories.LocationID  as region ,ProductInfo.Name as NameProduct,sum(ProductInventories.Quantity) as cantidad 
	from [Production].[ProductInventory] as ProductInventories
		INNER JOIN [Production].[Product] as ProductInfo on ProductInventories.ProductID = ProductInfo.ProductID
		GROUP BY [ProductInventories].[LocationID],[ProductInfo].[Name]) as regiones

--COUNT

SELECT COUNT(*) AS NoAscendidos FROM [Person].[Person] WHERE [EmailPromotion] = 0
SELECT COUNT(*) AS Ascendidos FROM [Person].[Person] WHERE [EmailPromotion] = 1	
SELECT COUNT(*) AS SinIdentificar FROM [Person].[Person] WHERE [EmailPromotion] not in (0,1)
 
 --- en una sola consulta seria

 SELECT [EmailPromotion] as tipoEmail, COUNT([EmailPromotion]) as cantidadDataEmail FROM [Person].[Person] GROUP BY [EmailPromotion]

 --- por tipo de titulo
 -- el count no cuentas los nulos
 -- dependera de que si nos sirve los valores nulos
 SELECT [Persons].[Title] as tipo, count([Persons].[Title]) as cantidad FROM [Person].[Person] as Persons group by [Persons].[Title]
 SELECT [Persons].[Title] as tipo, count(*) as cantidad FROM [Person].[Person] as Persons group by [Persons].[Title]

 --- apellidos repetidos
 
SELECT TOP 1 [Persons].LastName as apellido, count(*) as cantidad
	 FROM [Person].[Person] as Persons
	 GROUP BY [Persons].[LastName]
	 ORDER BY cantidad DESC

-- Genere una consulta sobre la tabla [HumanResources]. [Employee] que muestre BusinessEntityID, NationalIDNumber y JobTitle, 
--ordene los registros de mayor a menor por el campo BusinessEntityID.

SELECT [RH].BusinessEntityID, [RH].NationalIDNumber, [RH].JobTitle 
	FROM  [HumanResources].[Employee] AS RH
		ORDER BY [RH].BusinessEntityID DESC

--- Genere una consulta que permita obtener la cantidad por JobTitle. La consulta debe mostrar el campo JobTitle 
--seguido de la cantidad que hay por dicho JobTitle, ordene de mayor a menor.

SELECT [HR].JobTitle as trabajo, count([HR].JobTitle) as cantidad
	FROM [HumanResources].[Employee] AS HR 
	GROUP BY [HR].JobTitle
	ORDER BY cantidad DESC

--Realice una consulta de la tabla [HumanResources]. [Employee] la cual indique el promedio del campo VacationHours
--donde el JobTitle sea Production Technician - WC50, el campo resultante del promedio debe llamarse Promedio.

SELECT 'Production Technician - WC50' AS JOBTITLE, AVG([HR].VacationHours) AS PROMEDIO
	FROM [HumanResources]. [Employee] AS HR 
	WHERE [HR].JobTitle LIKE 'Production Technician - WC50'



--Realice una consulta de la tabla [Sales]. [SalesPerson] la cual indique la suma total del campo SalesYTD donde el campo TerritoryID no sea NULL,
-- el nuevo campo resultante debe llamarse SumaTotal.

SELECT SUM([SALESPERSONS].SalesYTD) AS SUMATOTALNOTNULL 
	 FROM [Sales].[SalesPerson] AS SALESPERSONS
	 WHERE [SALESPERSONS].TerritoryID IS NOT NULL
 