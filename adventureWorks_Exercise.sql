-- Adventure Works Ex.1
-- From the following table write a query in SQL to retrieve all rows and columns from the 
-- employee table in the Adventureworks database. Sort the result set in ascending order on jobtitle.

select * from HumanResources.Employee order by JobTitle asc

-- Adventure Works Ex.2
-- From the following table write a query in SQL to retrieve all rows and columns from the employee table using 
-- table alias ing in the Adventureworks database. Sort the output in ascending order on lastname

select personas.*
from Person.Person as personas
order by personas.LastName

-- Adventure Works Ex.3
-- From the following table write a query in SQL to return all rows and a subset of the columns (FirstName, LastName, businessentityid) from the person table in the AdventureWorks database.
-- The third column heading is renamed to Employee_id. Arranged the output in ascending order by lastname.

select FirstName,
	   LastName,
	   BusinessEntityID as Employee_id
	   from Person.Person

-- Adventure Works Ex.4
-- From the following table write a query in SQL to return only the rows for product that have a sellstartdate that is not NULL and a productline of 'T'.
-- Return productid, productnumber, and name. Arranged the output in ascending order on name

select 
	ProductID,
	ProductNumber,
	name
from Production.Product 
where SellStartDate IS NOT NULL and ProductLine = 'T'
order by name asc

-- Adventure Works Ex.5
--  From the following table write a query in SQL to return all rows from the salesorderheader table in Adventureworks database and 
--  calculate the percentage of tax on the subtotal have decided.Return salesorderid, customerid, orderdate, subtotal, percentage of tax column. 
--  Arranged the result set in ascending order on subtotal.

	--TaxAmt
	--1971,5149 it's the total value already with tax, we need find the percentage value
select soh.SalesOrderID,
	   soh.CurrencyRateID,
	   soh.OrderDate,	   
	   soh.SubTotal,
	   Concat(CONVERT(varchar,(TaxAmt*100)/SubTotal),' %') as Tax_percent
from Sales.SalesOrderHeader soh
order by soh.SubTotal desc

-- Adventure Works Ex.6
-- From the following table write a query in SQL to create a list of unique jobtitles in the employee table in Adventureworks database. 
-- Return jobtitle column and arranged the resultset in ascending order.

select JobTitle 
	 from HumanResources.Employee
	 group by JobTitle 
	 order by JobTitle asc

-- Adventure Works Ex.7
-- From the following table write a query in SQL to calculate the total freight paid by each customer. 
-- Return customerid and total freight. Sort the output in ascending order on customerid.

select soh.CustomerID,
	   soh.freight as 'total freight'
from Sales.SalesOrderHeader as soh 
group by soh.CustomerID,soh.freight
order by soh.CustomerID asc

-- Adventure Works Ex.8
-- From the following table write a query in SQL to find the average and the sum of the subtotal for every customer.
-- Return customerid, average and sum of the subtotal. Grouped the result on customerid and salespersonid. 
-- Sort the result on customerid column in descending order.

select soh.CustomerID,
	   soh.salespersonId,
	   (sum(soh.SubTotal)/count(soh.CustomerID)) as 'avg_subtotal',
	   sum(soh.SubTotal) as 'sum_subtotal'
from Sales.SalesOrderHeader as soh 
group by soh.CustomerID,soh.salespersonId
order by soh.CustomerID desc

-- Adventure Works Ex.9
-- From the following table write a query in SQL to retrieve total quantity of each productid which are in shelf of 'A' or 'C' or 'H'.
-- Filter the results for sum quantity is more than 500. Return productid and sum of the quantity. Sort the results according to the productid in ascending order.  

-- hay que tener en cuenta que primer se filtra por estantes, para asi luego agruparlos y poder tener como conjunto a cada producto, con esto podemos 
-- aplicar lo que seria alguna funcion de agregacion para sumar sus cantidades, ahora seria incorrecto ponerlo en el where por que filtrariamos por producto
-- y puede que sql tome cualquiera y no la suma de cada product id. sum(Prodinv.Quantity) > 500 ya por ultimo si podemos ordenarlos

select productid , sum(Quantity) as total_quantity
	from Production.ProductInventory as Prodinv
	where Prodinv.Shelf in ('A','C','H')
	group by Prodinv.ProductID
	having sum(Prodinv.Quantity) > 500
	order by Prodinv.ProductID asc

-- Adventure Works Ex.10
-- From the following table write a query in SQL to find the total quentity for a group of locationid multiplied by 10

select sum(prodInv.Quantity) as 'total_quantity' 
	from production.productinventory prodInv
	group by prodInv.LocationID*10

-- Adventure Works Ex.11
-- From the following tables write a query in SQL to find the persons whose last name starts with letter 'L'.
-- Return BusinessEntityID, FirstName, LastName, and PhoneNumber. Sort the result on lastname and firstname.
 
select personas.BusinessEntityID,
	   personas.FirstName,
	   personas.LastName,
	   perPhone.PhoneNumber
	   from [Person].[Person] as personas inner join 
	   [Person].[PersonPhone]  as perPhone on
	   personas.BusinessEntityID = perPhone.BusinessEntityID
	   where [personas].[LastName] like 'L%'
	   order by personas.LastName, personas.FirstName

-- Adventure Works Ex.12
-- From the following table write a query in SQL to find the sum of subtotal column. Group the sum on distinct salespersonid and customerid.
-- Rolls up the results into subtotal and running total. Return salespersonid, customerid and sum of subtotal column i.e. sum_subtotal.


-- solution 1
-- add where for better presentation, this query dont send the result of agregate function of our column subtotal
select SalesPersonID,
	   CustomerID,
	   sum(SubTotal) as 'sum_subtotal' 
	   from sales.salesorderheader	
	   where SalesPersonID is not null 
	   group by SalesPersonID,CustomerID
	   order by SalesPersonID,CustomerID

-- solution 2 
-- this solutions is the same of before, but here we use rollup that send us all combinatination posible and finally add a rows with the sum of all
-- value in aggregate_function(colum)

--here we are much NULL values that means 'consumidor final', so will use coalesce to rename it, means todas las ventas de consumidor final hacia 
-- comprador con customer id tal es ..

-- because the rollup always return the total of group and total of total 
SELECT COALESCE(CONVERT(VARCHAR,salespersonid), 'FINAL SALES') AS 'salespersonid',customerid,sum(subtotal) AS sum_subtotal
FROM sales.salesorderheader s 
where SalesPersonID is not null 
GROUP BY ROLLUP(s.SalesPersonID,s.CustomerID)

-- Adventure Works Ex.13
-- From the following table write a query in SQL to find the sum of the quantity of all combination of group of distinct locationid and shelf column. 
-- Return locationid, shelf and sum of quantity as TotalQuantity.

select LocationID,
	   Shelf,
	   sum(Quantity) as 'totalquantity'

	   from production.productinventory
	   group by CUBE(LocationID,Shelf)
	   order by LocationID asc

-- so the cube generate the combination in this case for the twice values of group, and we'll get 
-- en cada localidad la suma de cada estante por separado
-- en cada localidad la suma de todos los estantes 
-- la suma de todos los estantes en cada localidad (suma total)
-- la suma de todas las localidades por estante(a,j,l,..) 

SELECT COALESCE(CONVERT(varchar,locationid),'All location with') as 'location Id', COALESCE(shelf,'All Shelf') as 'shelf', SUM(quantity) AS TotalQuantity
FROM production.productinventory
GROUP BY CUBE (locationid, shelf);

-- Adventure Works Ex.14
-- From the following table write a query in SQL to find the sum of the quantity with subtotal for each locationid. 
-- Group the results for all combination of distinct locationid and shelf column. Rolls up the results into subtotal and running total.
-- Return locationid, shelf and sum of quantity as TotalQuantity.

SELECT locationid, shelf, SUM(quantity) AS TotalQuantity
FROM production.productinventory
GROUP BY GROUPING SETS ( ROLLUP (locationid, shelf), CUBE (locationid, shelf),())

-- en teoria el grouping sets lo usaremos para hacer una especie de union all, la cual nos permite agregar lo que seria dos querys 
-- en una sola data de informacion


-- Adventure Works Ex.15
-- From the following table write a query in SQL to find the total quantity for each locationid and calculate the grand-total for all locations.
-- Return locationid and total quantity. Group the results on locationid.

select COALESCE(Convert(varchar,LocationID),'Total All Location'),
       sum(Quantity)
	   from Production.ProductInventory
	   group by grouping sets ((LocationID),()) 
	   order by LocationID


-- Adventure Works Ex.16
-- From the following table write a query in SQL to retrieve the number of employees for each City. Return city and number of employees.
-- Sort the result in ascending order on city.

select City, 
	   count(City) as noofEmployes
	   from Person.Address 
	   group by city 
	   order by City

-- Adventure Works Ex.17
-- From the following table write a query in SQL to retrieve the total sales for each year. Return the year part of order date and total due amount. 
-- Sort the result in ascending order on year part of order date.

--sol: we us datePart that allow us to get a split of the date example 11-04-2022 
-- we send the first parameter yyyy or yy also can be other: https://learn.microsoft.com/en-us/sql/t-sql/functions/datepart-transact-sql?view=sql-server-ver16
-- finally we can group by for this and ordered too.
select DATEPART(yyyy,OrderDate) as 'Anio' , sum(orderHeader.TotalDue) as 'Order Amount'
	from Sales.SalesOrderHeader as orderHeader
	group by DATEPART(yyyy,OrderDate)
	order by DATEPART(yyyy,OrderDate)


-- Adventure Works Ex.18
-- From the following table write a query in SQL to retrieve the total sales for each year. 
-- Filter the result set for those orders where order year is on or before 2016.
-- Return the year part of orderdate and total due amount. Sort the result in ascending order on year part of order date.  
select DATEPART(yyyy,OrderDate) as 'Anio' , sum(orderHeader.TotalDue) as 'Order Amount'
	from Sales.SalesOrderHeader as orderHeader
	where DATEPART(yyyy,OrderDate)<=2016
	group by DATEPART(yyyy,OrderDate)
	order by DATEPART(yyyy,OrderDate)

-- Adventure Works Ex.19
-- From the following table write a query in SQL to find the contacts who are designated as a manager in various departments. 
-- Returns ContactTypeID, name. Sort the result set in descending order

select ContactTypeID,
	   name
	   from Person.ContactType
	   where name like '%Manager%'
	   order by ContactTypeID desc

-- Adventure Works Ex.20
-- From the following tables write a query in SQL to make a list of contacts who are designated as 'Purchasing Manager'. 
-- Return BusinessEntityID, LastName, and FirstName columns. Sort the result set in ascending order of LastName, and FirstName

select BEC.BusinessEntityID, PERS.LastName, PERS.FirstName 
	from Person.Person as PERS inner join Person.BusinessEntityContact as BEC on
	PERS.BusinessEntityID = BEC.PersonID
	inner join Person.ContactType as PerCt on 
	BEC.ContactTypeID = PerCt.ContactTypeID
	where PerCt.Name like 'Purchasing Manager'
	order by  PERS.LastName, PERS.FirstName 

-- Adventure Works Ex.21
-- From the following tables write a query in SQL to retrieve the salesperson for each PostalCode who belongs to a territory and SalesYTD is not zero. 
-- Return row numbers of each group of PostalCode, last name, salesytd, postalcode column. Sort the salesytd of each postalcode group in descending order.
-- Shorts the postalcode in ascending order.


--- ROW_NUMBER() over() es una agrupador sql que da mas soltura a la hora de no condicionar tanto como un group by 
--  contamos las columnas sobre la partition hecha en cada postal code y ademas ordemos por una columna SalesYTD en este caso
--  nos permite ademas obtener otra informacion de mas campos, cosa que no permite el group by

select ROW_NUMBER() over (PARTITION BY PerAd.postalcode order by sa.SalesYTD desc) as 'Num Colum',per.LastName,sa.SalesYTD,perad.PostalCode
	from Sales.SalesPerson Sa  
		inner join Person.Person Per 
		on Sa.BusinessEntityID = Per.BusinessEntityID 
		inner join Person.Address PerAd 
		on Sa.BusinessEntityID = PerAd.AddressID
		
-- Adventure Works Ex.22
-- From the following table write a query in SQL to count the number of contacts for combination of each type and name. 
-- Filter the output for those who have 100 or more contacts. Return ContactTypeID and ContactTypeName and BusinessEntityContact.
-- Sort the result set in descending order on number of contacts.

select CT.ContactTypeID,COUNT(CT.Name) AS nocontact,
	   CT.Name
	   from Person.BusinessEntityContact BEC inner join Person.ContactType CT on BEC.ContactTypeID = CT.ContactTypeID
	   GROUP BY CT.ContactTypeID, CT.NAME
	   HAVING COUNT(CT.Name) > 100
	   ORDER BY nocontact DESC

-- Adventure Works Ex.23
-- From the following table write a query in SQL to retrieve the RateChangeDate, full name (first name, middle name and last name)
-- and weekly salary (40 hours in a week) of employees. In the output the RateChangeDate should appears in date format. 
-- Sort the output in ascending order on NameInFull.

select CAST(HU.RateChangeDate AS varchar(12)),
	   CONCAT(PE.FirstName,PE.LastName) AS full_Name , (40*HU.Rate) as SalaryInAWeak
	   from HumanResources.EmployeePayHistory HU 
	   join Person.Person PE on HU.BusinessEntityID = PE.BusinessEntityID
	   order by full_Name


-- Adventure Works Ex.24
-- From the following tables write a query in SQL to calculate and display the latest weekly salary of each employee. 
-- Return RateChangeDate, full name (first name, middle name and last name) and weekly salary (40 hours in a week) of employees
-- Sort the output in ascending order on NameInFull.

-- se propone dos en la primera, se muestra el sueldo de los empleados por semana, en lo que se piensa que es la ultima semana registrada
SELECT CAST(hur.RateChangeDate as VARCHAR(10) ) AS FromDate
        , CONCAT(LastName, ', ', FirstName, ' ', MiddleName) AS NameInFull
        , (40 * hur.Rate) AS SalaryInAWeek
    FROM Person.Person AS pp
        INNER JOIN HumanResources.EmployeePayHistory AS hur
            ON hur.BusinessEntityID = pp.BusinessEntityID
             WHERE hur.RateChangeDate = (SELECT MAX(RateChangeDate)
                                FROM HumanResources.EmployeePayHistory
                                WHERE BusinessEntityID = hur.BusinessEntityID)
    ORDER BY NameInFull;

-- en la siguiente se presenta la solucion pero solo para los empleados que se registraron pago en la ultima semana de la data
select CAST(HU.RateChangeDate AS varchar(12)),
	   CONCAT(PE.FirstName,PE.LastName) AS full_Name , (40*HU.Rate) as SalaryInAWeak , *
	   from HumanResources.EmployeePayHistory HU 
	   join Person.Person PE on HU.BusinessEntityID = PE.BusinessEntityID
	   where HU.RateChangeDate = (SELECT MAX(RateChangeDate)
                                FROM HumanResources.EmployeePayHistory )


-- Adventure Works Ex.25
-- From the following table write a query in SQL to find the sum, average, count, minimum, and maximum order quentity for those orders whose id
-- are 43659 and 43664. 
-- Return SalesOrderID, ProductID, OrderQty, sum, average, count, max, and min order quantity.


-- este es el caso donde group by se queda corto entonces lo que se hara es usar el over partition

select SalesOrderID,ProductID,OrderQty,
	--total de productos
	sum(OrderQty) over(partition by SalesOrderID) as "Total quantaty product in order",
	--referencia el promedio del total de las veces que aparece
	avg(OrderQty) over(partition by SalesOrderID) as "Avg quantaty prdouct for single product",
	-- cantitad de veces con el id
	count(OrderQty) OVER (PARTITION BY SalesOrderID) AS "Num of products for single product"
	--orden maxima para un producto
    ,min(OrderQty) OVER (PARTITION BY SalesOrderID) AS "Min Quantity product for single product"
	--orden minima de un producto 
    ,max(OrderQty) OVER (PARTITION BY SalesOrderID) AS "Max Quantity product for single product"

	from Sales.SalesOrderDetail where SalesOrderID in (43659,43664)
	order by SalesOrderID


-- Adventure Works Ex.26
-- From the following table write a query in SQL to find the sum, average, and number of order quantity for those orders whose ids are 43659 and 43664
-- and product id starting with '71'. Return SalesOrderID, OrderNumber,ProductID, OrderQty, sum, average, and number of order quantity. 

select  SalesOrderID as orderNumber ,ProductID,OrderQty as "cantidad de producto por id",
	--total de productos in la orden
	sum(OrderQty) over(partition by SalesOrderID) as "Total quantaty product in order",
	--referencia el promedio del total de las veces que aparece
	avg(OrderQty) over(partition by SalesOrderID) as "Avg quantaty prdouct for single product",
	-- cantitad de veces con el id
	count(OrderQty) OVER (PARTITION BY SalesOrderID) AS "count total for single products in order" 

	from Sales.SalesOrderDetail where SalesOrderID in (43659,43664) and ProductID like '71%'

-- Adventure Works Ex.27
-- From the following table write a query in SQL to retrieve the total cost of each salesorderID that exceeds 100000.
-- Return SalesOrderID, total cost.

select SalesOrderID, sum(LineTotal) as "total cost order id"  
		from sales.SalesOrderDetail 
		group by SalesOrderID
		having sum(LineTotal) > 100000
		order by [total cost order id]

-- Adventure Works Ex.28
-- From the following table write a query in SQL to retrieve products whose names start with 'Lock Washer'.
-- Return product ID, and name and order the result set in ascending order on product ID column. 

select ProductID,Name
	from Production.Product
	where Name like 'Lock Washer%'
	order by ProductID

-- Adventure Works Ex.29
-- Write a query in SQL to fetch rows from product table and order the result set on an unspecified column listprice.
-- Return product ID, name, and color of the product. 

-- aunque no se traiga la columna como presentacion se puede usara para odernar los datos

SELECT ProductID, Name, Color  
FROM Production.Product  
ORDER BY ListPrice;

-- Adventure Works Ex.30
-- From the following table write a query in SQL to retrieve records of employees. 
-- Order the output on year (default ascending order) of hiredate. Return BusinessEntityID, JobTitle, and HireDate. 


select BusinessEntityID,
	   JobTitle,
	   HireDate
	   from HumanResources.Employee
	   order by HireDate

-- Adventure Works Ex.31
-- From the following table write a query in SQL to retrieve those persons whose last name begins with letter 'R'.
-- Return lastname, and firstname and display the result in ascending order on firstname and descending order on lastname columns.

SELECT LastName, FirstName 
FROM Person.Person  
WHERE LastName LIKE 'R%'  
ORDER BY FirstName ASC, LastName DESC ;

-- Adventure Works Ex.32
-- From the following table write a query in SQL to ordered the BusinessEntityID column descendingly 
-- when SalariedFlag set to 'true' and BusinessEntityID in ascending order when SalariedFlag set to 'false'. 
-- Return BusinessEntityID, SalariedFlag columns.

-- para este caso lo ordemaos en base al salariedFlag cuando es true entonces lo ordena el buinessEntityId descendinete
-- para el caso contrario hace el orden para la ordenacion por defecto
select BusinessEntityID,
	   Case when SalariedFlag = 1 then 'true'
	   ELSE 'false' END AS SalariedFlag
	   from HumanResources.Employee
	   order by case SalariedFlag when 'true' then BusinessEntityID END DESC,
				case when SalariedFlag = 'false' then BusinessEntityID end


-- Adventure Works Ex.33
-- From the following table write a query in SQL to set the result in order by the column TerritoryName 
-- when the column CountryRegionName is equal to 'United States' and by CountryRegionName for all other rows.


-- lo que buscamos es que cuando halle en CountryRegionName el pais de EEUU ordene por TerritoryName
-- sino es EEUU los ordene por CountryRegionName
select BusinessEntityID,
	   LastName,
	   TerritoryName, 
	   CountryRegionName 
	   from Sales.vSalesPerson
	   WHERE TerritoryName IS NOT NULL
	   
	   ORDER BY CASE CountryRegionName WHEN 'United States' THEN TerritoryName  
         ELSE CountryRegionName END;

-- Adventure Works Ex.34
-- From the following table write a query in SQL to find those persons who lives in a territory and the value of salesytd except 0.
-- Return first name, last name,row number as 'Row Number', 'Rank', 'Dense Rank' and NTILE as 'Quartile', salesytd and postalcode.
-- Order the output on postalcode column.

select * from Sales.SalesPerson
select * from Person.Person
select * from Person.Address

select PER.FirstName,
	PER.LastName,
	ROW_NUMBER() OVER (ORDER BY DIR.PostalCode) as RowNumber,
	RANK() OVER (ORDER BY DIR.PostalCode) AS "Rank",
	-- Rank asignara valores o categoria unica a cada registro en funcion de un valor especifico, si hay dos repetidos asignara el mismo valor
	-- pero se llevara el siguiente registro para seguir el orden implicito
	DENSE_RANK() OVER (ORDER BY DIR.PostalCode) AS "Dense Rank",
	-- Hace lo mismo que el rank pero sin omitir ningun registro
	NTILE(4) OVER (ORDER BY SP.SalesYTD) AS "Quartile",
	-- Esta funcion nos permite clasificar en base a algun campo por rangos, 1 a 100 ; 101 a 120.... y los hace caer dentro de un quartil.
	-- 
	SP.SalesYTD AS salesytd,
	DIR.PostalCode AS PostalCode
	from Sales.SalesPerson SP INNER JOIN Person.Person PER ON 
		SP.BusinessEntityID = PER.BusinessEntityID INNER JOIN Person.Address DIR ON
		PER.BusinessEntityID = DIR.AddressID
	where
	SP.TerritoryID IS NOT NULL AND
	SP.SalesYTD <> 0

-- Adventure Works Ex.35
-- From the following table write a query in SQL to skip the first 10 rows from the sorted result set and return all remaining rows.

-- existen varias formas de hacer esto.

-- primera
select * from  HumanResources.Department 
except
select top 10 * from  HumanResources.Department 

-- segunda
select * 
from HumanResources.Department 
where HumanResources.Department.DepartmentID  > 10
order by HumanResources.Department.DepartmentID

-- tercera
select * 
from HumanResources.Department
order by HumanResources.Department.DepartmentID OFFSET 10 ROWS

-- Existen limite y offset limit numero de filas devuelto por una consulta, y offset es el numero de filas a saltar para presentar la info.


-- Adventure Works Ex.36
-- From the following table write a query in SQL to skip the first 5 rows and return the next 5 rows from the sorted result set.

select * 
from HumanResources.Department
order by HumanResources.Department.DepartmentID OFFSET 5 ROWS 
	FETCH NEXT 5 ROWS ONLY
-- EN MYSQL SERVER al parecer no se puede usar limit y offset juntos
-- El recurso que presenta es FETCH NEXT 5 ROWS ONLY despues del OFFSET

-- Adventure Works Ex.37
-- From the following table write a query in SQL to list all the products that are Red or Blue in color.
-- Return name, color and listprice.Sorts this result by the column listprice. 

SELECT Name, Color, ListPrice  
FROM Production.Product  
WHERE Color = 'Red'  
UNION ALL  
SELECT Name, Color, ListPrice  
FROM Production.Product  
WHERE Color = 'Blue'  
ORDER BY ListPrice ASC;

SELECT Name, Color, ListPrice  
FROM Production.Product  
WHERE Color = 'Red' OR Color = 'Blue'
ORDER BY ListPrice ASC

-- Adventure Works Ex.38
-- Create a SQL query from the SalesOrderDetail table to retrieve the product name and any associated sales orders.
-- Additionally, it returns any sales orders that don't have any items mentioned in the Product table as well as any
-- products that have sales orders other than those that are listed there. Return product name, salesorderid. 
-- Sort the result set on product name column.

SELECT PP.Name, SOD.SalesOrderID FROM Sales.SalesOrderDetail SOD FULL OUTER JOIN Production.Product PP ON 
	SOD.ProductID = PP.ProductID
	ORDER BY PP.Name

SELECT p.Name, sod.SalesOrderID  
FROM Production.Product AS p  
FULL OUTER JOIN Sales.SalesOrderDetail AS sod  
ON p.ProductID = sod.ProductID  
ORDER BY p.Name ;

	-- Para este caso nos piden que traigamos las ordenes aunque no tenga un producto conocido, y a la vez el producto aun asi no tenga 
	-- una orden asociada



-- Adventure Works Ex.39
-- From the following table write a SQL query to retrieve the product name and salesorderid.
-- Both ordered and unordered products are included in the result set.

SELECT PP.Name, SOD.SalesOrderID FROM Sales.SalesOrderDetail SOD LEFT OUTER JOIN Production.Product PP ON 
	SOD.ProductID = PP.ProductID
	ORDER BY PP.Name

	SELECT PP.Name, SOD.SalesOrderID FROM Sales.SalesOrderDetail SOD FULL OUTER JOIN Production.Product PP ON 
	SOD.ProductID = PP.ProductID
	ORDER BY PP.Name

	-- LEFT OUTER JOIN === LEFT JOIN
	-- para estos dos casos se puede apreciar que seria uno para que me traiga los pedidos con coincidencia y los tambien en donde no halla pedido con producto conociodo
	-- en conclusion sin los nullos de la consulta anterior

-- Adventure Works Ex.40
-- From the following tables write a SQL query to get all product names and sales order IDs. Order the result set on product name column.

SELECT p.Name, sod.SalesOrderID  
FROM Production.Product AS p  
INNER JOIN Sales.SalesOrderDetail AS sod  
ON p.ProductID  sod.ProductID  
ORDER BY p.Name ;

-- EL LEFT Y EL INNER Nos van a traer los mismo resultados ya que los nulos estarian en la tabla de mi derecha por decirlo de alguna forma


-- Adventure Works Ex.41
--  From the following tables write a SQL query to retrieve the territory name and BusinessEntityID.
--  The result set includes all salespeople, regardless of whether or not they are assigned a territory.

select CASE WHEN ST.Name is NULL THEN 'No Especificado' 
		ELSE ST.Name 
		END AS Name, 
		SP.BusinessEntityID
		from  Sales.SalesPerson as SP LEFT OUTER JOIN Sales.SalesTerritory as ST ON
			SP.TerritoryID = ST.TerritoryID 



-- Adventure Works Ex.42
-- Write a query in SQL to find the employee's full name (firstname and lastname) and city from the following tables. 
-- Order the result set on lastname then by firstname

CREATE INDEX IX_PERSON_BUSSINES_ENTITY ON PERSON.person(BusinessEntityID)

select CONCAT(P.FirstName,P.MiddleName,P.LastName) AS 'Nombre Completo',
    PA.City 
	from Person.Person as P INNER JOIN 
		 HumanResources.Employee as RRH 
		 ON P.BusinessEntityID = RRH.BusinessEntityID INNER JOIN 
		 Person.BusinessEntityAddress as PBE
		 ON RRH.BusinessEntityID = PBE.BusinessEntityID INNER JOIN
		 Person.Address as PA
		 ON PBE.AddressID = PA.AddressID
		 ORDER BY P.LastName,P.FirstName

-- Adventure Works Ex.43
-- Write a SQL query to return the businessentityid,firstname and lastname columns of all persons in the person table (derived table) 
-- with persontype is 'IN' and the last name is 'Adams'. Sort the result set in ascending order on firstname.
-- A SELECT statement after the FROM clause is a derived table.  


SELECT 
	DP.BusinessEntityID,
	DP.FirstName,
	DP.LastName
	FROM
		(SELECT *
			FROM Person.Person as P
			WHERE P.PersonType = 'IN' and P.LastName = 'Adams') as DP

-- Adventure Works Ex.44
-- Create a SQL query to retrieve individuals from the following table with a businessentityid inside 1500,
-- a lastname starting with 'Al', and a firstname starting with 'M'

SELECT 
	P.BusinessEntityID,
	P.FirstName,
	P.LastName
	FROM Person.Person AS P
	WHERE P.BusinessEntityID <= 1500 AND P.LastName LIKE '%Al%' AND FirstName LIKE '%M%' 
	
		
-- Adventure Works Ex.45
-- Write a SQL query to find the productid, name, and colour of the items 'Blade', 'Crown Race' and 'AWC Logo Cap' using a derived table with multiple values.


SELECT 
	DPROD.ProductID,
	DPROD.Name,
	DPROD.Color 
		FROM (SELECT *
				FROM Production.Product AS PROD 
				WHERE PROD.Name IN ('Blade', 'Crown Race' , 'AWC Logo Cap')) AS DPROD



-- Adventure Works Ex.46
-- Create a SQL query to display the total number of sales orders each sales representative receives annually.
-- Sort the result set by SalesPersonID and then by the date component of the orderdate in ascending order.
-- Return the year component of the OrderDate, SalesPersonID, and SalesOrderID.


WITH Sales_CTE (SalesPersonID, SalesOrderID, SalesYear)
AS
(
    SELECT SalesPersonID, SalesOrderID, year(OrderDate) AS SalesYear
    FROM Sales.SalesOrderHeader
    WHERE SalesPersonID IS NOT NULL
)


SELECT SalesPersonID, COUNT(SalesOrderID) AS TotalSales, SalesYear
FROM Sales_CTE
GROUP BY SalesYear, SalesPersonID -- Se crea una tabla derivada, con esto podemos sacar los atributos necesarios para poder usarlos luego
ORDER BY SalesPersonID, SalesYear; -- se agrupa por salesYear para asi contar las ventas y con la agrupacion de salesPersonid logramos agrupar a la vez por id
								-- por ultimo ordenamos por en sentido contrario por lo que asi traemos los datos de la primera consulta 


-- Adventure Works Ex.47 
-- From the following table write a query in SQL to find the average number of sales orders for all the years of the sales representatives

 SELECT SH.SalesPersonID , COUNT(SalesOrderID) AS VENTAS , year(OrderDate) AS ANIO FROM Sales.SalesOrderHeader AS SH
    WHERE SalesPersonID IS NOT NULL
	GROUP BY  year(OrderDate), SalesPersonID
	ORDER BY SalesPersonID

WITH AVERAGE_SELL(SalesPersonID,TOTAL_SELL)
AS
(
	SELECT SalesPersonID, COUNT(SalesOrderID) AS TOTAL_SELL FROM Sales.SalesOrderHeader AS SH
    WHERE SalesPersonID IS NOT NULL
	GROUP BY SalesPersonID

)

SELECT AVG(TOTAL_SELL) AS 'AVERAGE SALES PER PERSON' FROM AVERAGE_SELL


-- Adventure Works Ex.48 
-- Write a SQL query on the following table to retrieve records with the characters greena_ in the LargePhotoFileName field.
-- The following table's columns must all be returned.

SELECT *   
FROM Production.ProductPhoto PPP
WHERE PPP.LargePhotoFileName LIKE '%greena_%' ESCAPE 'a' ; -- para esto caso pudimos dejarle sin el greena en green, el escape se usa para obviar por decirlo de alguna forma
-- lo que seria algun caracter.


-- Adventure Works Ex.49
-- Write a SQL query to retrieve the mailing address for any company that is outside the United States (US) and in a city whose name starts with Pa.
-- Return Addressline1, Addressline2, city, postalcode, countryregioncode columns.

select 
	PA.AddressLine1,
	CASE WHEN PA.AddressLine2 IS NULL THEN ''
	ELSE PA.AddressLine2 
	END AS AddressLine2,
	PA.City,
	PSP.CountryRegionCode,PA.PostalCode
	from Person.Address as PA INNER JOIN
	Person.StateProvince AS PSP ON
	PA.StateProvinceID = PSP.StateProvinceID
	WHERE PSP.CountryRegionCode <> 'US' AND PA.City LIKE 'Pa%'
	ORDER BY PSP.CountryRegionCode DESC
	

-- Adventure Works Ex.50
-- From the following table write a query in SQL to fetch first twenty rows. Return jobtitle, hiredate.
-- Order the result set on hiredate column in descending order.

SELECT TOP 20 JobTitle, HireDate  
FROM HumanResources.Employee
ORDER BY HireDate desc
--FETCH FIRST 20 ROWS ONLY; este ultimo es usado para otro motro de base de datos


--  Adventure Works Ex.51
--  From the following tables write a SQL query to retrieve the orders with orderqtys greater than 5 or unitpricediscount less than 1000.
--  and totaldues greater than 100. Return all the columns from the tables

SELECT * 
	FROM Sales.SalesOrderHeader AS SOH INNER JOIN 
	Sales.SalesOrderDetail AS SOD ON
	SOH.SalesOrderID = SOD.SalesOrderID
	WHERE SOD.OrderQty > 5 OR SOD.UnitPriceDiscount < 1000 AND (SOH.TotalDue > 100)


--  Adventure Works Ex.52
--  From the following table write a query in SQL that searches for the word 'red' in the name column. Return name, and color columns from the table.

-- DECLARE @SearchWord NVARCHAR(30)  
-- SET @SearchWord = N'red'  
-- Es una opcion para resolver pero no funciona para todos los motores de base de datos.

SELECT Name, Color   
FROM Production.Product 
WHERE Name LIKE '%red%'


-- Adventure Works Ex.53
-- From the following table write a query in SQL to find all the products with a price of $80.99 that contain the word Mountain. Return name, and listprice columns from the table

SELECT PINFO.Name, PINFO.ListPrice
	FROM Production.Product AS PINFO 
		WHERE PINFO.ListPrice = 80.99 AND 
			  PINFO.Name LIKE '%Mountain%'

-- Adventure Works Ex.54
-- From the following table write a query in SQL to retrieve all the products that contain either the phrase Mountain or Road. Return name, and color columns

SELECT PINFO.Name,
	CASE WHEN PINFO.Color IS NULL THEN 'sin registro'
	ELSE PINFO.color 
	END AS Color
	FROM Production.Product AS PINFO 
		WHERE PINFO.Name LIKE '%Mountain%' OR 
			  PINFO.Name LIKE '%Road%'


-- Adventure Works Ex.55
-- From the following table write a query in SQL to search for name which contains both the word 'Mountain' and the word 'Black'. Return Name and color.

SELECT PINFO.Name,
	CASE WHEN PINFO.Color IS NULL THEN 'sin registro'
	ELSE PINFO.color 
	END AS Color
	FROM Production.Product AS PINFO 
		WHERE PINFO.Name LIKE '%Mountain%' AND
			  PINFO.Name LIKE '%Black%'

-- Adventure Works Ex.56
-- From the following table write a query in SQL to return all the product names with at least one word starting with the prefix 'chain' in the Name column

SELECT PINFO.Name,
	CASE WHEN PINFO.Color IS NULL THEN 'sin registro'
	ELSE PINFO.color 
	END AS Color
	FROM Production.Product AS PINFO 
		WHERE PINFO.Name LIKE '%chain%'

-- Adventure Works Ex.57
-- From the following table write a query in SQL to return all the product names with at least one word starting with the prefix 'chain' in the Name column

SELECT PINFO.Name,
	CASE WHEN PINFO.Color IS NULL THEN 'sin registro'
	ELSE PINFO.color 
	END AS Color
	FROM Production.Product AS PINFO 
		WHERE PINFO.Name LIKE '%chain%' OR PINFO.Name LIKE '%%'

-- Adventure Works Ex.58
-- From the following table write a SQL query to output an employee's name and email address, separated by a new line character

SELECT 
    CONCAT(CONCAT(PINFO.FirstName,CONCAT(' ',PINFO.LastName + ' ')),PEA.EmailAddress) AS USER_EMAIL
	FROM Person.Person AS PINFO INNER JOIN Person.EmailAddress AS PEA ON
	PINFO.BusinessEntityID = PEA.BusinessEntityID

-- Adventure Works Ex.59
-- CHARINDEX(substring, string, start)
-- From the following table write a SQL query to locate the position of the string "yellow" where it appears in the product name.

SELECT PROD.Name,
	   CHARINDEX('Chain',PROD.Name) AS CHAR_INIT 
	   FROM Production.Product AS PROD


-- Adventure Works Ex.60
-- From the following table write a query in SQL to concatenate the name, color, and productnumber columns.

SELECT CONCAT( name, '   color:-',color,' Product Number:', productnumber ) AS result, color
FROM production.product;

-- Adventure Works Ex.61
-- Write a SQL query that concatenate the columns name, productnumber, colour, and a new line character from the following table, each separated by a specified character.

SELECT CONCAT_WS( ',', production.product.name, productnumber, color) AS DatabaseInfo
FROM production.product;

-- Adventure Works Ex.62
-- From the following table write a query in SQL to return the five leftmost characters of each product name.

SELECT SUBSTRING(PROD.Name,1,5) AS MOST_LEFT FROM  production.product AS PROD

-- Adventure Works Ex.63
-- From the following table write a query in SQL to select the number of characters and the data in FirstName for people located in Australia

SELECT LEN(VVC.FirstName) AS COUNT_FIRST_NAME,
	   VVC.FirstName,
	   VVC.LastName 
	   FROM Sales.vindividualcustomer VVC 
	   WHERE VVC.CountryRegionName = 'Australia'


-- Adventure Works Ex.64
-- From the following tables write a query in SQL to return the number of characters in the column FirstName and the first and last name of contacts located in Australia

SELECT DISTINCT LEN(FirstName) AS FNameLength, FirstName, LastName   
FROM Sales.vstorewithcontacts  AS e  
INNER JOIN Sales.vstorewithaddresses AS g   
    ON e.businessentityid = g.businessentityid   
WHERE CountryRegionName = 'Australia';


-- Adventure Works Ex.65
-- From the following table write a query in SQL to select product names that have prices between $1000.00 and $1220.00. Return product name as Lower, Upper, and also LowerUpper.

SELECT LOWER(SUBSTRING(Name, 1, 25)) AS Lower,   
       UPPER(SUBSTRING(Name, 1, 25)) AS Upper,   
       LOWER(UPPER(SUBSTRING(Name, 1, 25))) As LowerUpper  
FROM production.Product  
WHERE standardcost between 1000.00 and 1220.00;

-- Adventure Works Ex.66
-- Write a query in SQL to remove the spaces from the beginning of a string. 

SELECT  '   Texto con espacio incluido ' as "Original Text",
LTRIM('   Texto con espacio incluido ') as "Without Spaces in the init or end";

-- Adventure Works Ex.67
-- From the following table write a query in SQL to remove the substring 'HN' from the start of the column productnumber.
-- Filter the results to only show those productnumbers that start with "HN". Return original productnumber column and 'TrimmedProductnumber'.


SELECT PROD.Name,
	   REPLACE(SUBSTRING(Name,LEN('Mountain') + 1,LEN(Name)),'-','') AS REST
	   FROM production.Product AS PROD
	   WHERE PROD.Name LIKE 'Mountain%' 

-- Adventure Works Ex.68
-- From the following table write a query in SQL to repeat a 0 character four times in front of a production line for production line 'T'.
-- exists certain built-function that are different with respect transact sql or pure sql

SELECT Name , concat(REPLICATE('0', 4) , ProductLine) AS "Line Code" 
FROM Production.Product  
WHERE ProductLine = 'T'  
ORDER BY Name;

-- Adventure Works Ex.69
-- From the following table write a SQL query to retrieve all contact first names with the characters inverted for people whose businessentityid is less than 6

SELECT FirstName, REVERSE(FirstName) AS Reverse  
FROM Person.Person  
WHERE BusinessEntityID < 6 
ORDER BY FirstName;

-- Adventure Works Ex.70
-- From the following table write a query in SQL to return the eight rightmost characters of each name of the product. Also return name, productnumber column.
-- Sort the result set in ascending order on productnumber.

SELECT SUBSTRING(PROD.Name,LEN(PROD.Name)-8,LEN(PROD.Name)) AS RIGHT_MOST FROM  production.product AS PROD WHERE LEN(PROD.Name) > 8

-- Adventure Works Ex.71
-- Write a query in SQL to remove the spaces at the end of a string. 

SELECT  '   Texto con espacio incluido ' as "Original Text",
LTRIM('   Texto con espacio incluido ') as "Without Spaces in the init or end";


-- Adventure Works Ex.71
--A "Single Item Order" is a customer order where only one item is ordered. Show the SalesOrderID and the UnitPrice for every Single Item Order.


WITH ID_ONE_SELL (SalesOrderID,Cantidad,UnitPrice)
AS (
	SELECT SOD.SalesOrderID , COUNT(*) AS cantidad , SOD.UnitPrice FROM Sales.SalesOrderDetail as SOD 
	GROUP BY SOD.SalesOrderID,SOD.UnitPrice
	HAVING  COUNT(*)  = 1
)

SELECT SalesOrderID , UnitPrice FROM ID_ONE_SELL


-- Adventure Works Ex.72
-- For every customer with a 'Main Office' in Dallas show AddressLine1 of the 'Main Office' and AddressLine1 of the 'Shipping' address - if there is no shipping address leave it blank. Use one row per customer.

--SELECT VSWA.AddressLine1, BillToAddressID  ,* FROM Sales.SalesOrderHeader SOH INNER JOIN Sales.Customer SCU  ON SOH.CustomerID = SCU.CustomerID
--INNER JOIN Sales.vStoreWithAddresses VSWA ON SOH.BillToAddressID = VSWA.BusinessEntityID 
--WHERE VSWA.City LIKE 'Dallas'

--SELECT SOH.ShipToAddressID  ,* FROM Sales.SalesOrderHeader SOH INNER JOIN Sales.Customer SCU  ON SOH.CustomerID = SCU.CustomerID
--INNER JOIN Sales.vStoreWithAddresses VSWA ON SOH.BillToAddressID = VSWA.BusinessEntityID 
--WHERE VSWA.City LIKE 'Dallas'
-- no esta muy clara 


-- Adventure Works Ex.73
-- Show the best selling item by value.

-- forma 1 
select * from Production.Product where ProductID in (
	select ProductID from (select top 1 ProductID, sum(LineTotal) as totalFacturado from Sales.SalesOrderDetail
	group by ProductID order by totalFacturado desc	) a
	) 

-- forma 2

with id_most_selling (id,total) as (
	select top 1 ProductID, sum(LineTotal) as totalFacturado from Sales.SalesOrderDetail
	group by ProductID order by totalFacturado desc
)

-- Adventure Works Ex.74

select * from Production.Product where ProductID in (select id from id_most_selling)

-- Adventure Works Ex.75

SELECT BusinessEntityID, FirstName, MiddleName, LastName
FROM Person.Person
WHERE MiddleName LIKE '[E,B]'; -- este nos sirve como una especie de lista de donde se pueden sacar valores para discriminar

-- Adventure Works Ex.76

SELECT LastName
FROM Person.Person
WHERE LastName LIKE 'Ja%es'; --- % cualquier cantidad de caracteres que reemplace el %

-- Adventure Works Ex.77

SELECT LastName
FROM Person.Person
WHERE LastName LIKE 'Ja_es'; -- _ solo va a poder ser reemplazado por uno

-- Adventure Works Ex.78

SELECT COALESCE ('Shobha','Shivakumar')