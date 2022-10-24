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

