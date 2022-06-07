

--RETURNING PEOPLE DATA

WITH PeopleData AS

(
	SELECT P.BusinessEntityID, CONCAT(P.FirstName, ' ', LastName) AS PersonName, A.AddressLine1 AS Address, A.City, A.PostalCode,
	SP.Name AS State, CR.Name AS Country
	FROM Person.Person AS P
		INNER JOIN Person.BusinessEntity AS BE
		ON P.BusinessEntityID = BE.BusinessEntityID
			INNER JOIN Person.BusinessEntityAddress AS BEA
			ON BEA.BusinessEntityID = BE.BusinessEntityID
				INNER JOIN Person.Address AS A
				ON BEA.AddressID = A.AddressID
					INNER JOIN Person.StateProvince AS SP
					ON SP.StateProvinceID = A.StateProvinceID
						INNER JOIN Person.CountryRegion AS CR
						ON CR.CountryRegionCode = SP.CountryRegionCode
					
)

SELECT BusinessEntityID, PersonName, Address, City, PostalCode,
State, Country
FROM PeopleData;



--PEOPLE GRUOP BY COUNTRY

WITH PeopleByCountry AS

(
	SELECT P.BusinessEntityID, CONCAT(P.FirstName, ' ', LastName) AS PersonName, A.AddressLine1 AS Address, A.City, A.PostalCode,
	SP.Name AS State, CR.Name AS Country
	FROM Person.Person AS P
		INNER JOIN Person.BusinessEntity AS BE
		ON P.BusinessEntityID = BE.BusinessEntityID
			INNER JOIN Person.BusinessEntityAddress AS BEA
			ON BEA.BusinessEntityID = BE.BusinessEntityID
				INNER JOIN Person.Address AS A
				ON BEA.AddressID = A.AddressID
					INNER JOIN Person.StateProvince AS SP
					ON SP.StateProvinceID = A.StateProvinceID
						INNER JOIN Person.CountryRegion AS CR
						ON CR.CountryRegionCode = SP.CountryRegionCode
					
)
 
SELECT COUNT(PersonName) AS AmountPeople, Country
FROM PeopleByCountry
GROUP BY Country
ORDER BY AmountPeople DESC;




--AMOUNT OF PEOLE OUTSIDE USA

WITH PeopleOutUSA AS

(
	SELECT P.BusinessEntityID, CONCAT(P.FirstName, ' ', LastName) AS PersonName, A.AddressLine1 AS Address, A.City, A.PostalCode,
	SP.Name AS State, CR.Name AS Country
	FROM Person.Person AS P
		INNER JOIN Person.BusinessEntity AS BE
		ON P.BusinessEntityID = BE.BusinessEntityID
			INNER JOIN Person.BusinessEntityAddress AS BEA
			ON BEA.BusinessEntityID = BE.BusinessEntityID
				INNER JOIN Person.Address AS A
				ON BEA.AddressID = A.AddressID
					INNER JOIN Person.StateProvince AS SP
					ON SP.StateProvinceID = A.StateProvinceID
						INNER JOIN Person.CountryRegion AS CR
						ON CR.CountryRegionCode = SP.CountryRegionCode
					
)

SELECT SUM(AmountPeople) AS PeopleOut
FROM (SELECT COUNT(PersonName) AS AmountPeople
		FROM PeopleOutUSA
		WHERE Country NOT LIKE 'United States'
		GROUP BY Country
		) AS D


--PERCENTAGE OF PEOPLE OUTSIDE USA


WITH PercCustOut AS

(
	SELECT P.BusinessEntityID, CONCAT(P.FirstName, ' ', LastName) AS PersonName, A.AddressLine1 AS Address, A.City, A.PostalCode,
	SP.Name AS State, CR.Name AS Country
	FROM Person.Person AS P
		INNER JOIN Person.BusinessEntity AS BE
		ON P.BusinessEntityID = BE.BusinessEntityID
			INNER JOIN Person.BusinessEntityAddress AS BEA
			ON BEA.BusinessEntityID = BE.BusinessEntityID
				INNER JOIN Person.Address AS A
				ON BEA.AddressID = A.AddressID
					INNER JOIN Person.StateProvince AS SP
					ON SP.StateProvinceID = A.StateProvinceID
						INNER JOIN Person.CountryRegion AS CR
						ON CR.CountryRegionCode = SP.CountryRegionCode
					
)

SELECT COUNT(*) * 100.0 / (SELECT COUNT(*) FROM PercCustOut) AS PercentageOut
FROM PercCustOut
WHERE Country NOT LIKE 'United States';



--PEOPLE BY ADDRESS TYPE


WITH CustAddrType AS

(
	SELECT P.BusinessEntityID, CONCAT(P.FirstName, ' ', LastName) AS PersonName, A.AddressLine1 AS Address, A.City, A.PostalCode,
	SP.Name AS State, CR.Name AS Country, ATY.Name AS AddrType
	FROM Person.Person AS P
		INNER JOIN Person.BusinessEntity AS BE
		ON P.BusinessEntityID = BE.BusinessEntityID
			INNER JOIN Person.BusinessEntityAddress AS BEA
			ON BEA.BusinessEntityID = BE.BusinessEntityID
				INNER JOIN Person.Address AS A
				ON BEA.AddressID = A.AddressID
					INNER JOIN Person.StateProvince AS SP
					ON SP.StateProvinceID = A.StateProvinceID
						INNER JOIN Person.CountryRegion AS CR
						ON CR.CountryRegionCode = SP.CountryRegionCode
							INNER JOIN Person.AddressType AS ATY
							ON ATY.AddressTypeID = BEA.AddressTypeID
					
)

SELECT COUNT(PersonName) AS AmountPeople, AddrType
FROM CustAddrType
GROUP BY AddrType;


--AMOUNT SPENT PER CUSTOMER


SELECT C.CustomerID, SUM(SOH.TotalDue) AS AmountSpnt
FROM Sales.Customer AS C
	INNER JOIN Sales.SalesOrderHeader AS SOH
	ON SOH.CustomerID = C.CustomerID
GROUP BY C.CustomerID;



--CUSTOMER WITH NO SALE ORDERS

SELECT C.CustomerID, CASE								
						WHEN SUM(SOH.TotalDue) IS NULL THEN 'NO ORDER PLACED'
						END AS AmountSpnt
FROM Sales.Customer AS C
	LEFT JOIN Sales.SalesOrderHeader AS SOH
	ON SOH.CustomerID = C.CustomerID
GROUP BY C.CustomerID
HAVING SUM(SOH.TotalDue) IS NULL;


--SALES BY COUNTRY


WITH SalesinOut AS

(
	SELECT SOH.TotalDue, CR.Name AS Country
	FROM Sales.Customer AS C
		INNER JOIN Sales.SalesOrderHeader AS SOH
		ON C.CustomerID = SOH.CustomerID
			INNER JOIN Person.Address AS A
			ON A.AddressID = SOH.ShipToAddressID
				INNER JOIN Person.StateProvince AS SP
				ON SP.StateProvinceID = A.StateProvinceID
					INNER JOIN Person.CountryRegion AS CR
					ON CR.CountryRegionCode = SP.CountryRegionCode

)

SELECT SUM(TotalDue) TotalSales, Country 
FROM SalesinOut
GROUP BY Country;



--EMPLOYEE INFORMATION AND SALARIES

SELECT P.BusinessEntityID, E.NationalIDNumber, CONCAT(P.FirstName,  ' ', P.LastName) AS EmployeeName, E.JobTitle,
E.BirthDate, E.Gender, YEAR(E.HireDate) AS HireDate, EPH.Rate * 2087 AS AnnualSalary, EPH.PayFrequency
FROM Person.Person AS P
	LEFT JOIN HumanResources.Employee AS E
	ON E.BusinessEntityID = P.BusinessEntityID
		INNER JOIN HumanResources.EmployeePayHistory AS EPH
		ON EPH.BusinessEntityID = E.BusinessEntityID
WHERE E.NationalIDNumber IS NOT NULL;



--AVERAGE PAY BY GENDER

WITH AvgPayGender AS

(
	SELECT P.BusinessEntityID, E.NationalIDNumber, CONCAT(P.FirstName,  ' ', P.LastName) AS EmployeeName, E.JobTitle,
	E.BirthDate, E.Gender, YEAR(E.HireDate) AS HireDate, EPH.Rate * 2087 AS AnnualSalary, EPH.PayFrequency
	FROM Person.Person AS P
		LEFT JOIN HumanResources.Employee AS E
		ON E.BusinessEntityID = P.BusinessEntityID
			INNER JOIN HumanResources.EmployeePayHistory AS EPH
			ON EPH.BusinessEntityID = E.BusinessEntityID
	WHERE E.NationalIDNumber IS NOT NULL

)

SELECT AVG(AnnualSalary) AS AvgAnnualSalary, Gender
FROM AvgPayGender
GROUP BY Gender;


--SALES BY STORES

WITH Sales AS 

(
	SELECT  S.BusinessEntityID AS StoreID, A.City, SOH.TotalDue, SOH.OrderDate
	FROM Sales.Store AS S
		INNER JOIN Person.BusinessEntity AS BE
		ON BE.BusinessEntityID = S.BusinessEntityID
			INNER JOIN Person.BusinessEntityAddress AS BEA
			ON BEA.BusinessEntityID = BE.BusinessEntityID
				INNER JOIN Person.Address AS A
				ON A.AddressID = BEA.AddressID
					INNER JOIN Sales.SalesOrderHeader AS SOH
					ON SOH.ShipToAddressID = A.AddressID
)

SELECT StoreID, SUM(TotalDue) AS AmountSales, City 
FROM Sales
GROUP BY StoreID, City;



	
WITH SalesYear AS 

(
	SELECT  S.BusinessEntityID AS StoreID, A.City, SOH.TotalDue, SOH.OrderDate
	FROM Sales.Store AS S
		INNER JOIN Person.BusinessEntity AS BE
		ON BE.BusinessEntityID = S.BusinessEntityID
			INNER JOIN Person.BusinessEntityAddress AS BEA
			ON BEA.BusinessEntityID = BE.BusinessEntityID
				INNER JOIN Person.Address AS A
				ON A.AddressID = BEA.AddressID
					INNER JOIN Sales.SalesOrderHeader AS SOH
					ON SOH.ShipToAddressID = A.AddressID
)

SELECT StoreID, SUM(TotalDue) AmountSales, YEAR(OrderDate)
FROM SalesYear
GROUP BY StoreID, YEAR(OrderDate);



--SALE BY CREDIT CARDS

SELECT CreditCardID, SUM(TotalDue) AS SalesAmount
FROM (SELECT CreditCardID, SalesPersonID, TotalDue
				FROM Sales.SalesOrderHeader
			) AS CreditCardSales 
GROUP BY CreditCardID;




--SALES MADE BY CREDIT CARDS INCLUDING THE SALES PERSON

SELECT SUM(TotalDue) AS SalesAmount, SalesPersonID, CreditCardID
FROM (SELECT CreditCardID, SalesPersonID, TotalDue
				FROM Sales.SalesOrderHeader
			) AS CreditCardSales 
			INNER JOIN Sales.SalesPerson AS SP
			ON SP.BusinessEntityID = CreditCardSales.SalesPersonID
GROUP BY SalesPersonID, CreditCardID;



--CITIES SHARED BY CUSTOMERS AND EMPLOYEES


SELECT A.City 
FROM Sales.Customer AS C
	INNER JOIN Person.Person AS P 
	ON C.CustomerID = P.BusinessEntityID
		INNER JOIN Person.BusinessEntity AS BE
		ON P.BusinessEntityID = BE.BusinessEntityID
			INNER JOIN Person.BusinessEntityAddress AS BEA
			ON BEA.BusinessEntityID = BE.BusinessEntityID
				INNER JOIN Person.Address AS A
				ON A.AddressID = BEA.AddressID

INTERSECT

SELECT A.City
FROM HumanResources.Employee AS E
	INNER JOIN Person.Person AS P
	ON E.BusinessEntityID = P.BusinessEntityID
		INNER JOIN Person.BusinessEntity AS BE
		ON BE.BusinessEntityID = P.BusinessEntityID
			INNER JOIN Person.BusinessEntityAddress AS BEA
			ON BEA.BusinessEntityID = BE.BusinessEntityID
				INNER JOIN Person.Address AS A
				ON A.AddressID = BEA.AddressID;



--TOP 10 MOST EXPENSIVE PURCHASES 

SELECT TOP(10) SalesOrderID, CreditCardID, CustomerID, DATENAME(YEAR, OrderDate) AS Year, 
FORMAT(TotalDue, 'C') AS PurchaseAmount,
		ROW_NUMBER() OVER(ORDER BY TotalDue DESC) AS MostExpensivePurchase
FROM Sales.SalesOrderHeader 
ORDER BY TotalDue DESC;



--RANKING OF PURCHASE PER CUSTOMERS


SELECT SalesOrderID, CustomerID, DATENAME(YEAR, OrderDate) AS Year, 
FORMAT(TotalDue, 'C') AS PurchaseAmount,
		ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY TotalDue DESC) AS RanktExpensivePurchase
FROM Sales.SalesOrderHeader; 



--MOST EXPENSIVE PURCHASE PER CUSTOMER

WITH CustomerPurch AS 

(
	SELECT SalesOrderID, CustomerID, DATENAME(YEAR, OrderDate) AS Year, 
	FORMAT(TotalDue, 'C') AS PurchaseAmount,
			ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY TotalDue DESC) AS RankExpensivePurchase
	FROM Sales.SalesOrderHeader 
)

SELECT SalesOrderID, CustomerID, Year, PurchaseAmount
FROM CustomerPurch
WHERE RankExpensivePurchase = 1 


--RANKING OF PURCHASE PER CUSTOMERS W/ SAME PURCHASE AMOUNT


SELECT SalesOrderID, CustomerID, DATENAME(YEAR, OrderDate) AS Year, 
FORMAT(TotalDue, 'C') AS PurchaseAmount,
		DENSE_RANK() OVER(PARTITION BY CustomerID ORDER BY TotalDue DESC) AS RanktExpensivePurchase
FROM Sales.SalesOrderHeader;



--AMOUNT OF PRODUCT BY SUBCATEGORY ID INCLUDING PRODUCTS 
--W/ NO SUBCATEGORY ID

SELECT ProductID, Name, ProductSubcategoryID,
	COUNT(ProductID) OVER(PARTITION BY ProductSubcategoryID) AS TotalProduct
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL;


--TOTAL AMOUNT OF PRODUCTS ORDER BY SUBCATEGORY

SELECT ProductID, Name, ProductSubcategoryID,
	COUNT(ProductID) OVER(order BY ProductSubcategoryID DESC) AS TotalProduct
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL
ORDER BY TotalProduct DESC;


--TOTAL OF ORDER PER CUSTOMERS

SELECT SalesOrderID, CustomerID, DATENAME(YEAR, OrderDate) AS Year, 
	COUNT(SalesOrderID) OVER(PARTITION BY CustomerID) AS TotalOfOrders
FROM Sales.SalesOrderHeader;


--REVENUE PER CUSTOMER

SELECT SalesOrderID, CustomerID, DATENAME(YEAR, OrderDate) AS Year, 
	COUNT(SalesOrderID) OVER(PARTITION BY CustomerID) AS AmountOfOrders,
	SUM(TotalDue) OVER(PARTITION BY CustomerID) AS Revenue
FROM Sales.SalesOrderHeader;



--CUSTOMERS ANALYSIS IN ORDER AND REVENUE RATIOS

SELECT SalesOrderID, CustomerID, DATENAME(YEAR, OrderDate) AS Year, 
	COUNT(SalesOrderID) OVER(PARTITION BY CustomerID) AS TotalOfOrdersByCustomers,
	FORMAT(SUM(TotalDue) OVER(PARTITION BY CustomerID), 'C') AS TotalRevenueByCustomers,
	FORMAT(SUM(TotalDue) OVER(), 'C') AS TotalRevenue,
	FORMAT(SUM(TotalDue) OVER(PARTITION BY CustomerId) / SUM(TotalDue) OVER(), 'P') AS CustomersRevenueRatio
FROM Sales.SalesOrderHeader
ORDER BY CustomersRevenueRatio DESC;



--MONTHLY AND ANNUAL SALES

SELECT YEAR(OrderDate) AS Year, MONTH(OrderDate) AS Month, 
		FORMAT(SUM(TotalDue) OVER(PARTITION BY YEAR(OrderDate), MONTH(OrderDate)), 'C') AS MonthlySales,
		FORMAT(SUM(TotalDue) OVER(PARTITION BY YEAR(OrderDate)), 'C') AS AnnuaSales
FROM Sales.SalesOrderHeader;



--% OF ANNUAL SALES

WITH PercentAnnualSales AS

(

	SELECT  DISTINCT YEAR(OrderDate) AS Year, MONTH(OrderDate) AS Month, 
		SUM(TotalDue) OVER(PARTITION BY YEAR(OrderDate), MONTH(OrderDate)) AS MonthlySales,
		SUM(TotalDue) OVER(PARTITION BY YEAR(OrderDate)) AS AnnualSales
	FROM Sales.SalesOrderHeader
	

)

SELECT Year, Month, 
	FORMAT(MonthlySales, 'C') AS MonthlySales, 
	FORMAT(AnnualSales, 'C') AS AnnualSales,
	FORMAT(MonthlySales / AnnualSales, 'P') AS PercentMonthlyAnnualSales, 
	DENSE_RANK() OVER(PARTITION BY YEAR ORDER BY MonthlySales DESC) AS RankAnnualSales
FROM PercentAnnualSales
ORDER BY Year, Month;







--BEST PERFORMING MONTH PER YEAR

WITH PercentAnnualSales AS

(

	SELECT  DISTINCT YEAR(OrderDate) AS Year, MONTH(OrderDate) AS Month, 
		SUM(TotalDue) OVER(PARTITION BY YEAR(OrderDate), MONTH(OrderDate)) AS MonthlySales,
		SUM(TotalDue) OVER(PARTITION BY YEAR(OrderDate)) AS AnnualSales
	FROM Sales.SalesOrderHeader
	
),

BestPerforMonth AS
(

	SELECT Year, Month, 
		FORMAT(MonthlySales, 'C') AS MonthlySales, 
		FORMAT(AnnualSales, 'C') AS AnnualSales,
		FORMAT(MonthlySales / AnnualSales, 'P') AS PercentMonthlyAnnualSales, 
		DENSE_RANK() OVER(PARTITION BY YEAR ORDER BY MonthlySales DESC) AS RankAnnualSales
	FROM PercentAnnualSales

)

SELECT Year, Month, MonthlySales, PercentMonthlyAnnualSales, AnnualSales
FROM BestPerforMonth
WHERE RankAnnualSales = 1
ORDER BY Year, Month;



--ANNUAL RUNNING TOTAL

WITH RunningAnnualValue AS

(

	SELECT YEAR(OrderDate) AS Year, SUM(TotalDue) AS AnnualSales
	FROM Sales.SalesOrderHeader
	GROUP BY YEAR(OrderDate)

)

SELECT Year, FORMAT(AnnualSales, 'C') AS AnnualSales, 
	FORMAT(SUM(AnnualSales) OVER(ORDER BY Year 
		RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 'C') AS TotalRevenue
FROM RunningAnnualValue