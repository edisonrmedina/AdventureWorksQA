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