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
	sum(OrderQty) over(partition by SalesOrderID) as 'Total quantaty',
	--referencia el promedio del total de las veces que aparece
	avg(OrderQty) over(partition by SalesOrderID) as 'Avg quantaty',
	-- cantitad de veces con el id
	count(OrderQty) OVER (PARTITION BY SalesOrderID) AS "No of Orders"
	--orden maxima para un producto
    ,min(OrderQty) OVER (PARTITION BY SalesOrderID) AS "Min Quantity"
	--orden minima de un producto 
    ,max(OrderQty) OVER (PARTITION BY SalesOrderID) AS "Max Quantity"

	from Sales.SalesOrderDetail where SalesOrderID in (43659,43664)
	order by SalesOrderID
