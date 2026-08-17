CREATE TABLE online_retail_raw(
	Invoice					VARCHAR(20),
	StockCode				VARCHAR(20),
	Description				VARCHAR(100),
	Quantity				INT,
	InvoiceDate				DATE,
	Price					DECIMAL,
	CustomerID				INT,
	Country					VARCHAR(30)
);

SELECT * FROM online_retail_raw;

SELECT COUNT(*) FROM online_retail_raw; --it gave a total value of 1048575

SELECT * FROM online_retail_raw
LIMIT 50;

--Which information is missing from this dataset
SELECT COUNT(*) AS Total_rows, COUNT(CustomerID) AS customer_id_present,
		COUNT(*)-COUNT(CustomerID) AS customer_id_missing
FROM online_retail_raw;

--Did the system accidentally record the same transaction twice?
SELECT * , COUNT(*) FROM online_retail_raw
GROUP BY 
Invoice, StockCode, Description, Quantity, InvoiceDate, Price, CustomerID, Country
HAVING COUNT(*)>1;

--Invalid Quantities
SELECT * FROM online_retail_raw
WHERE Quantity <= 0;

--Invalid Prices
SELECT * FROM online_retail_raw
WHERE Price <= 0;

--Created a new table for me to work with(online_retail_clean)
CREATE TABLE online_retail_clean AS SELECT * FROM online_retail_raw;

SELECT * FROM online_retail_clean;

SELECT COUNT(*) FROM online_retail_clean;

--What business problem is the missing values causing 
--Could the missing values be due to data entry omission,system error,customer refused to register.

SELECT * FROM online_retail_clean
WHERE CustomerID IS NULL;

SELECT COUNT(*) AS Missing_CustomerID FROM online_retail_clean
WHERE CustomerID IS NULL;

/*This duplicated values are they true duplicate or legitimate repeated transactions.
And also could duplicated transactions be inflating the sales, why does this duplicates exist*/
SELECT COUNT(*) AS Total_rows, COUNT(CustomerID) AS customer_id_present,
		COUNT(*)-COUNT(CustomerID) AS customer_id_missing
FROM online_retail_clean;

/*What business event produces a negative quantity. Does the negative quantity represents 
Customer returns, refunds or cancelled orders */
SELECT * FROM online_retail_clean
WHERE Quantity < 0;

SELECT COUNT(*) AS negative_quantity_rows
FROM online_retail_clean
WHERE Quantity < 0;

SELECT * FROM online_retail_clean
WHERE Quantity < 0
ORDER BY InvoiceDate;

/* Zero or negative unit price could it be due to promotional giveaways, internal testing
or data entry errors. does it fit the business context*/
SELECT * FROM online_retail_clean
WHERE Price <= 0;

SELECT COUNT(*) AS Zero_or_negative_prices 
FROM online_retail_clean
WHERE Price <= 0;

SELECT Invoice, StockCode, Description, Quantity, Price, CustomerID, Country
FROM online_retail_clean
WHERE Price <= 0
ORDER BY InvoiceDate;

--Building the Schemas
--Customers table
CREATE TABLE Customers(					--Customers tables created to Normalize the dataset
	CustomerID INT PRIMARY KEY,
	Country VARCHAR(100)
);

INSERT INTO Customers(CustomerID, Country) --this returned error because a customer id appeared twice
	SELECT DISTINCT CustomerID, Country
FROM online_retail_clean
WHERE CustomerID IS NOT NULL;


INSERT INTO Customers(CustomerID, Country)
	SELECT DISTINCT CustomerID, Country
FROM online_retail_clean
WHERE CustomerID IS NOT NULL
AND CustomerID NOT IN (
	SELECT CustomerID FROM Customers
);

INSERT INTO Customers(CustomerID, Country) --this query omitted a customer that appeared in two country
	SELECT DISTINCT CustomerID, Country
FROM online_retail_clean
WHERE CustomerID IS NOT NULL
ON CONFLICT (CustomerID)
DO NOTHING;

SELECT COUNT(*) FROM Customers;

SELECT CustomerID, Country FROM Customers -- the customer with the id appeared in spain and france why
WHERE CustomerID = 12413;

--let me investigate why the customer id appears in spain and in france
SELECT CustomerID, Country, COUNT(*) AS Transactions, MIN(InvoiceDate) AS First_purchase,
		MAX(InvoiceDate) AS Last_purchase
		FROM online_retail_clean
		WHERE CustomerID = 12413
GROUP BY CustomerID, Country
ORDER BY First_purchase;

--how many customers appeared in more than one country
SELECT COUNT(*) FROM (
	SELECT CustomerID FROM online_retail_clean --this shows that only 13 customers made purchase 
	WHERE CustomerID IS NOT NULL 				-- from two different countries
	GROUP BY CustomerID
	HAVING COUNT(DISTINCT Country)>1
) AS Multi_country_customers;

/*to populate the customer table i have to give this condition for those 
customers that there id appeared in two countries with the condition that sql should take the 
details of the customer in the country that has the highest order as the customer main location*/
WITH CountryFrequency AS (
		SELECT CustomerID, Country, COUNT(*) AS OrderCount,
		ROW_NUMBER() OVER ( --this is called window functions in SQL
			PARTITION BY CustomerID --this gave a ranking for the customers automatically 
			ORDER BY COUNT(*) DESC, Country
		) AS rn
		FROM online_retail_clean
		WHERE CustomerID IS NOT NULL
		GROUP BY CustomerID, Country
)
	INSERT INTO Customers (CustomerID, Country)
	SELECT 
		CustomerID,
		Country
FROM CountryFrequency
WHERE rn = 1;

TRUNCATE TABLE Customers CASCADE; --this helped me to delete all the records in customer table

SELECT COUNT(*) FROM Customers;

--checking for duplicates if any 
SELECT CustomerID, COUNT(*) FROM Customers -- this show no duplicate values found 
GROUP BY CustomerID
HAVING COUNT(*)>1;

SELECT * FROM Customers -- Now it shows only france because that is where the highest no of order
WHERE CustomerID = 12413;

SELECT * FROM Customers;

--PRODUCTS TABLE

CREATE TABLE Products(
	StockCode		VARCHAR(20) PRIMARY KEY,
	Description 	VARCHAR(300) NOT NULL
);

INSERT INTO Products(StockCode, Description) -- This returned error that a stockcode 23191 already exist
SELECT DISTINCT StockCode, Description
FROM online_retail_clean
WHERE StockCode IS NOT NULL
AND Description IS NOT NULL;

--Let me carefully investigate the reason behind this before i populate the products table
SELECT StockCode, Description,
		COUNT(*) AS Total_transactions
	FROM online_retail_clean
	WHERE StockCode = '23191'
GROUP BY StockCode, Description
ORDER BY Total_Transactions DESC;

--How many stockcode has more than one description
SELECT COUNT(*) FROM (
		SELECT StockCode --this output shows 1,218 products has the same description
		FROM online_retail_clean
		GROUP BY StockCode
		HAVING COUNT(DISTINCT Description) > 1
) AS MultipleDescription;

--Lets find out the total number of unique stockcodes 
SELECT COUNT(*) AS Total_Stockcodes --this gave 5,304 unique products
	FROM(
		SELECT StockCode
		FROM online_retail_clean
		GROUP BY StockCode
	) AS t;

--lets find out how many unique descirptions 
SELECT 
	COUNT(DISTINCT Description) AS Total_Descriptions --we have 5,692 descriptions
FROM online_retail_clean;

--find the products with the highest descriptions 
SELECT StockCode, COUNT(DISTINCT Description) AS Description_Count
FROM online_retail_clean
GROUP BY StockCode
ORDER BY Description_Count DESC
LIMIT 20;

--Populating the table now we will use the following approach
WITH ProductDescription AS (
		SELECT StockCode, Description, COUNT(*) AS DescriptionCount,
		ROW_NUMBER() OVER ( --this is called window functions in SQL
			PARTITION BY StockCode --this gave a ranking for the customers automatically 
			ORDER BY COUNT(*) DESC, Description
		) AS rn
		FROM online_retail_clean
		WHERE StockCode IS NOT NULL
		AND Description IS NOT NULL
		GROUP BY StockCode, Description
)
	INSERT INTO Products (StockCode, Description)
	SELECT 
		StockCode,
		Description
FROM ProductDescription
WHERE rn = 1;

SELECT * FROM Products;

SELECT StockCode, COUNT(*) FROM Products
GROUP BY StockCode
HAVING COUNT(*) > 1;

--ORDER TABLE
CREATE TABLE Orders(
	Invoice			VARCHAR(20) PRIMARY KEY,
	CustomerID		INT REFERENCES Customers(CustomerID), --Foreign key referenced to customer table
	InvoiceDate		TIMESTAMP,
	OrderStatus		VARCHAR(20)
);

--Populate the order table
INSERT INTO Orders(Invoice, CustomerID, InvoiceDate, OrderStatus)
	SELECT DISTINCT Invoice, CustomerID, InvoiceDate,
	CASE
		WHEN Invoice LIKE 'C%' THEN 'Cancelled'
		ELSE 'Completed'
	END AS OrderStatus
FROM online_retail_clean
WHERE CustomerID IS NOT NULL;

--Check how many orders were loaded
SELECT COUNT(*) FROM Orders;

--Check for duplicate invoices 
SELECT Invoice, COUNT(*) FROM Orders
GROUP BY Invoice
HAVING COUNT(*) > 1;

SELECT * FROM Orders;

--ORDERSDETAILS TABLE
CREATE TABLE OrderDetails(
	Invoice 		VARCHAR(20) REFERENCES Orders(Invoice), --Foreign key referenced to order table 
	StockCode 		VARCHAR(20) REFERENCES Products(StockCode), --referenced to products table 
	Quantity		INT,
	Price 			NUMERIC(10,2)
);

INSERT INTO OrderDetails(Invoice, StockCode, Quantity, Price)
	SELECT 
	O.Invoice, 
	P.StockCode, 
	r.Quantity, 
	r.Price
FROM online_retail_clean r
JOIN Orders O
ON r.Invoice = O.Invoice	
JOIN Products P
ON r.StockCode = P.StockCode;

SELECT * FROM OrderDetails;

--EXECUTIVE KPI DEVELOPMENT USING SQL
--KPI 1 TOTAL REVENUE
SELECT SUM(Quantity * Price) AS Total_Revenue
FROM OrderDetails Od
INNER JOIN Orders O
	ON Od.Invoice = o.Invoice
WHERE o.OrderStatus = 'Completed';

--KPI 2 Total Orders
SELECT COUNT(*) AS Total_Order
FROM Orders
WHERE OrderStatus = 'Completed';

--KPI 3 Total Customers
SELECT COUNT(*) AS Total_Customers
FROM Customers;

--KPI 4 Total Products
SELECT COUNT(*) AS Total_Products
FROM Products;

--KPI 5 Average Order Value(AOV)
SELECT SUM(Od.Quantity * Od.Price)
			/COUNT(DISTINCT O.Invoice) AS Average_Order_Value
	FROM OrderDetails Od
INNER JOIN Orders o
ON Od.Invoice = O.Invoice
WHERE O.OrderStatus = 'Completed';

--Combination of all the KPI'S in one QUERY
SELECT 
	SUM(Od.Quantity * Od.Price) AS Total_Revenue,
	COUNT(DISTINCT O.Invoice) AS Total_Orders,
	COUNT(DISTINCT O.CustomerID) AS Total_Customers,
	COUNT(DISTINCT Od.StockCode) AS Total_Products,
	SUM(Od.Quantity) AS Total_Unit_Sold,
ROUND (
	SUM(Od.Quantity * Od.Price)
	/ COUNT(DISTINCT O.Invoice),2
) AS Average_Order_Value,
ROUND (
	SUM(Od.Quantity) :: DECIMAL
	/ COUNT(DISTINCT O.Invoice),2
) AS Average_Items_Per_Order
FROM OrderDetails Od
INNER JOIN Orders O
	ON Od.Invoice =O.Invoice
WHERE O.OrderStatus = 'Completed';




