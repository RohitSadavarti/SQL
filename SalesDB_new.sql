CREATE DATABASE SalesDB;
USE SalesDB;

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    ContactName VARCHAR(100),
    Country VARCHAR(50)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    SupplierID INT,
    CategoryID INT,
    UnitPrice DECIMAL(10, 2),
    UnitsInStock INT
);

CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY,
    SupplierName VARCHAR(100),
    ContactName VARCHAR(100),
    Country VARCHAR(50)
);

CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100),
    Description TEXT
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    EmployeeID INT,
    OrderDate DATE,
    ShipperID INT
);

CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT
);

CREATE TABLE Shippers (
    ShipperID INT PRIMARY KEY,
    ShipperName VARCHAR(100),
    Phone VARCHAR(20)
);

-- Insert sample data
INSERT INTO Customers (CustomerID, CustomerName, ContactName, Country) VALUES
(1, 'Alfreds Futterkiste', 'Maria Anders', 'Germany'),
(2, 'Ana Trujillo Emparedados y helados', 'Ana Trujillo', 'Mexico'),
(3, 'Antonio Moreno Taquería', 'Antonio Moreno', 'Mexico');

INSERT INTO Suppliers (SupplierID, SupplierName, ContactName, Country) VALUES
(1, 'Exotic Liquids', 'Charlotte Cooper', 'UK'),
(2, 'New Orleans Cajun Delights', 'Shelley Burke', 'USA'),
(3, 'Grandma Kellys Homestead', 'Regina Murphy', 'USA');

INSERT INTO Categories (CategoryID, CategoryName, Description) VALUES
(1, 'Beverages', 'Soft drinks, coffees, teas, beers, and ales'),
(2, 'Condiments', 'Sweet and savory sauces, relishes, spreads, and seasonings');

INSERT INTO Products (ProductID, ProductName, SupplierID, CategoryID, UnitPrice, UnitsInStock) VALUES
(1, 'Chai', 1, 1, 18.00, 39),
(2, 'Chang', 1, 1, 19.00, 17),
(3, 'Aniseed Syrup', 1, 2, 10.00, 13);

INSERT INTO Shippers (ShipperID, ShipperName, Phone) VALUES
(1, 'Speedy Express', '555-1234'),
(2, 'United Package', '555-5678');

INSERT INTO Orders (OrderID, CustomerID, EmployeeID, OrderDate, ShipperID) VALUES
(1, 1, 1, '2023-06-01', 1),
(2, 2, 2, '2023-06-15', 2),
(3, 3, 3, '2023-07-01', 1);

INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity) VALUES
(1, 1, 1, 10),
(2, 2, 2, 20),
(3, 3, 3, 30);

-- List all customers
SELECT * FROM Customers;

-- List all orders
SELECT * FROM Orders;

-- List all orderdetails
SELECT * FROM OrderDetails;

-- List all products
SELECT * FROM Products;

-- List all orders with customer details
SELECT Orders.OrderID, Customers.CustomerName, Orders.OrderDate
FROM Orders
JOIN Customers ON Orders.CustomerID = Customers.CustomerID;

-- List order details with product information
SELECT OrderDetails.OrderID, Products.ProductName, OrderDetails.Quantity, Products.UnitPrice
FROM OrderDetails
JOIN Products ON OrderDetails.ProductID = Products.ProductID;

-- Total sales per product
SELECT Products.ProductName, SUM(OrderDetails.Quantity * Products.UnitPrice) AS TotalSales
FROM OrderDetails
JOIN Products ON OrderDetails.ProductID = Products.ProductID
GROUP BY Products.ProductName;

-- Total orders per customer
SELECT Customers.CustomerName, COUNT(Orders.OrderID) AS TotalOrders
FROM Orders
JOIN Customers ON Orders.CustomerID = Customers.CustomerID
GROUP BY Customers.CustomerName;

-- Orders placed in the last month
SELECT * FROM Orders
WHERE OrderDate >= DATEADD(MONTH, -1, GETDATE());

-- Products with low stock
SELECT * FROM Products
WHERE UnitsInStock < 10;

-- Monthly sales trends
SELECT FORMAT(OrderDate, 'yyyy-MM') AS Month, 
       SUM(OrderDetails.Quantity * Products.UnitPrice) AS MonthlySales
FROM Orders
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
JOIN Products ON OrderDetails.ProductID = Products.ProductID
GROUP BY FORMAT(OrderDate, 'yyyy-MM')
ORDER BY FORMAT(OrderDate, 'yyyy-MM');

-------------- Top 5 customers by total sales
SELECT TOP 5 
       Customers.CustomerName, 
       SUM(OrderDetails.Quantity * Products.UnitPrice) AS TotalSales
FROM Orders
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
JOIN Products ON OrderDetails.ProductID = Products.ProductID
JOIN Customers ON Orders.CustomerID = Customers.CustomerID
GROUP BY Customers.CustomerName
ORDER BY TotalSales DESC;

-- Cumulative sales by month using the MonthlySalesData CTE
WITH MonthlySalesData AS (
    SELECT 
        CONVERT(VARCHAR(7), OrderDate, 126) AS Month, -- Format as yyyy-MM
        SUM(OrderDetails.Quantity * Products.UnitPrice) AS MonthlySales
    FROM Orders
    JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
    JOIN Products ON OrderDetails.ProductID = Products.ProductID
    GROUP BY CONVERT(VARCHAR(7), OrderDate, 126) -- Group by yyyy-MM
)
-------------
SELECT
    Month,
    MonthlySales,
    SUM(MonthlySales) OVER (ORDER BY Month) AS CumulativeSales
FROM MonthlySalesData
ORDER BY Month;

-- Products that have never been ordered
WITH MonthlySalesData AS (
    SELECT 
        CAST(FORMAT(OrderDate, 'yyyyMM') AS INT) AS Month,
        SUM(OrderDetails.Quantity * Products.UnitPrice) AS MonthlySales
    FROM Orders
    JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
    JOIN Products ON OrderDetails.ProductID = Products.ProductID
    GROUP BY CAST(FORMAT(OrderDate, 'yyyyMM') AS INT)
)
SELECT 
    Month, 
    MonthlySales, 
    SUM(MonthlySales) OVER (ORDER BY Month) AS CumulativeSales
FROM MonthlySalesData
ORDER BY Month;

SELECT ProductName
FROM Products
WHERE ProductID NOT IN (SELECT ProductID FROM OrderDetails);

