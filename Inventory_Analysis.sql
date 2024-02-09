CREATE DATABASE Inventory;
USE Inventory;

# --------------------------------------- Importing Customers Dataset -------------------------------------------- #

CREATE TABLE Customers(Cust_Key int primary key,
                       Cust_Name varchar(255),
                       Cust_City varchar(255),
                       Cust_State varchar(255),
                       Cust_County varchar(255),
                       Cust_Region varchar(255));
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Inventory\\Customers.csv" INTO TABLE Customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
ignore 1 lines;
SELECT * FROM Customers;

# --------------------------------------- Importing Stores Dataset ---------------------------------------------- #

CREATE TABLE Stores(Store_Key int primary key,
                    Store_Name varchar(255),
                    Store_City varchar(255),
                    Store_State varchar(255),
                    Store_County varchar(255),
                    Store_Region varchar(255),
                    Latitude float,
                    Longitude float);
                    
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Inventory\\Stores.csv" INTO TABLE Stores
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
ignore 1 lines;
SELECT * FROM Stores;

# ------------------------------------------- Importing Sales Dataset ------------------------------------ #

CREATE TABLE Sales(Order_Number int primary key,
                   Cust_key int,
                   Store_Key int,
                   Date date);
				
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Inventory\\Sales.csv" INTO TABLE Sales
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
ignore 1 lines;
SELECT * FROM Sales;

# -------------------------------------- Importing Products Dataset --------------------------------------- #

CREATE TABLE Products(Product_Key int primary key,
                      Product_Type varchar(255),
                      Product_Family varchar(255),
                      Product_Line varchar(255),
                      Sku_Number varchar(255),
                      Price float);
                      
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Inventory\\Products.csv" INTO TABLE Products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
ignore 1 lines;
SELECT * FROM Products;

# ------------------------------------- Importing Point_of_sale Dataset --------------------------------------- #

CREATE TABLE Point_of_sale(Order_Number int,
						   Product_Key int,
                           Sales_Quantity int,
                           Sales_Amount float,
                           Cost_Amount float);

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Inventory\\Point_of_sale.csv" INTO TABLE Point_of_sale
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
ignore 1 lines;
SELECT * FROM Point_of_sale;

# --------------------------------------- Importing Lab_Data Dataset ----------------------------------------------- #

CREATE TABLE Lab_Data(Order_Number int, Date date,Sku_Number varchar(255),Quantity int,Cost float,Price float,Product_Type varchar(255),
                       Product_Family varchar(255),Store_Name varchar(255),Store_Key int,Store_Region varchar(255),Store_State varchar(255),
                       Store_City varchar(255),Customer_Name varchar(255),Cust_Key int);
					
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Inventory\\Lab_Data.csv" INTO TABLE Lab_Data
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
ignore 1 lines;
SELECT * FROM Lab_Data;

# ----------------------------------------- Importing Inventory_Adjusted Dataset ---------------------------------- #

CREATE TABLE Inventory_Adjusted(Product_Key int primary key,Product_Type varchar(255),Product_Family varchar(255),Product_Line varchar(255),
                                Sku_Number varchar(255),Price float,Cost_Amount float,Quantity_on_Hand int);
                                
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Inventory\\Inventory_Adjusted.csv" INTO TABLE Inventory_Adjusted
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
ignore 1 lines;
SELECT * FROM Inventory_Adjusted;

# ----------------------------------------- Importing Stock_Availibility Dataset ---------------------------------- #

CREATE TABLE Stocks(Order_Number int,
						   Product_Key int,
                           Sales_Quantity int,
                           Sales_Amount float,
                           Cost_Amount float,
                           product_Type varchar(255),
                           Quantity_on_hand int,
                           Stocks int,
                           Availibility varchar(255));

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Inventory\\Stocks.csv" INTO TABLE Stocks
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
ignore 1 lines;
Select * From Stocks;

# --------------------------------- TOTAL SALES ------------------------------------ #
# --------- YTD --------- #
WITH YTD As (
SELECT Year(s.date) AS Year,
CONCAT(ROUND(SUM(p.sales_amount)/POWER(10,6),2)," M") AS Sales
FROM
 sales AS s
 JOIN 
 point_of_sale AS p
 ON
 s.Order_Number = p.Order_Number 
 GROUP BY Year(s.date)
 )
SELECT
Year,
Sales,
CONCAT(ROUND(SUM(Sales)
OVER (ORDER BY Year),2)," M")AS YTD
FROM YTD;

# ------- QTD ------ #
WITH QTD As (
SELECT CONCAT(year(s.date)," Q",Quarter(s.date))AS Quarter,
CONCAT(ROUND(SUM(p.sales_amount)/POWER(10,6),2),"M") AS "Sales"
FROM
 sales AS s
 JOIN 
 point_of_sale AS p
 ON
 s.Order_Number = p.Order_Number 
 GROUP BY Quarter 
 )
SELECT
QUARTER,
Sales,
CONCAT(ROUND(SUM(Sales)
OVER (ORDER BY Quarter),2),"M")AS QTD 
FROM QTD;

# --------- MTD -------- #
WITH MTD As (
SELECT CONCAT(year(s.date)," ",Monthname(s.date))AS Month,
CONCAT(ROUND(SUM(p.sales_amount)/POWER(10,6),2),"M") AS "Sales"
FROM
 sales AS s
 JOIN 
 point_of_sale AS p
 ON
 s.Order_Number = p.Order_Number 
 GROUP BY Month
 ORDER BY Month ASC
 )
SELECT
Month,
Sales,
CONCAT(ROUND(SUM(Sales)
OVER (ORDER BY Month ASC),2),"M")AS MTD 
FROM MTD;


	# --------------------------------- PRODUCT WISE SALES ------------------------------------ #
SELECT i.Product_Type,
CONCAT(ROUND(SUM(p.Sales_Amount)/POWER(10,6),2),"M") AS Sales 
FROM
 inventory_adjusted AS i
JOIN 
 point_of_sale AS p 
ON 
 i.Product_Key = p.Product_Key
GROUP BY 
 i.Product_Type 
ORDER BY 
 SUM(p.Sales_Amount) DESC;

  # ----------------------------------- SALES GROWTH ---------------------------------------- #
  select * from Sales;
  SELECT
    year(s.date) AS "Year",
    CONCAT(ROUND(SUM(p.sales_amount)/POWER(10,6),2),"M") AS "Sales",
   IFNULL(
   CONCAT( ROUND((SUM(p.sales_amount) - LAG(SUM(p.sales_amount)) OVER (ORDER BY year(s.date))) / LAG(SUM(p.sales_amount)) OVER (ORDER BY year(s.date)) * 100, 2),"%"),
   0)
   AS "Sales Growth"
FROM
    sales s
JOIN
    point_of_sale p ON s.order_number = p.order_number
GROUP BY
    YEAR(s.date)
ORDER BY
    YEAR(s.date);
    
  # ------------------------------- SALES TREND MONTHLY ------------------------------------- #
   SELECT
    month(s.date) AS "Month",
    CONCAT(ROUND(SUM(p.sales_amount)/POWER(10,6),2),"M") AS "Sales",
   IFNULL(
   CONCAT( ROUND((SUM(p.sales_amount) - LAG(SUM(p.sales_amount)) OVER (ORDER BY month(s.date))) / LAG(SUM(p.sales_amount)) OVER (ORDER BY month(s.date)) * 100, 2),"%"),
   0)
   AS "Sales Growth"
FROM
    sales s
JOIN
    point_of_sale p ON s.order_number = p.order_number
GROUP BY
    MONTH(s.date)
ORDER BY
    MONTH(s.date);

 # ---------------------------------- STATE WISE SALES ---------------------------------------- #
SELECT l.Store_State,
   CONCAT(ROUND(SUM(p.Sales_Amount)/POWER(10,6),2),"M") as Sales
FROM
   lab_data AS l 
JOIN
   point_of_sale AS p
 ON
   l.Order_Number = p.Order_Number
GROUP BY
  l.Store_State
ORDER BY 
  SUM(Sales_Amount) DESC;

# ------------------------------- TOP 5 STORE WISE SALES ------------------------------------- #
SELECT l.Store_Name,
 CONCAT(ROUND(SUM(p.Sales_Amount)/POWER(10,6),2),"M") as Sales
FROM
    lab_data AS l 
JOIN
  point_of_sale AS p
ON
  l.Order_Number = p.Order_Number
GROUP BY
 l.Store_Name 
 ORDER BY
 SUM(Sales_Amount) DESC limit 5;
    
# -------------------------------- REGION WISE SALES -------------------------------------- #
SELECT l.Store_Region,
CONCAT(ROUND(SUM(p.Sales_Amount)/POWER(10,6),2),"M") as Sales 
FROM
lab_data AS l 
JOIN
point_of_sale AS p ON
l.Order_Number = p.Order_Number
GROUP BY
 l.Store_Region 
 ORDER BY
 SUM(Sales_Amount) DESC;

# ------------------------------- TOTAL INVENTORY ------------------------------------- #
SELECT SUM(Quantity_on_Hand) AS Total_Inventory FROM inventory_adjusted;

# ------------------------------- INVENTORY VALUE ------------------------------------- #
ALTER TABLE inventory_adjusted ADD COLUMN Value float;
SELECT Price * Quantity_on_hand FROM inventory_adjusted;
UPDATE inventory_adjusted as i SET Value = (SELECT i.Price * i.Quantity_on_hand) ;
SELECT * FROM inventory_adjusted;
SELECT CONCAT(ROUND(SUM(Value)/POWER(10,6),2),"M") as Inventory_Value FROM inventory_adjusted;

# ------------------------------- STOCK AVAILABILITY ------------------------------------- #
Select * from Stocks;
SELECT
    s.product_type AS "product_type",
    SUM(CASE WHEN s.stocks < 0 THEN 1 ELSE 0 END) AS "Out Of Stock",
    SUM(CASE WHEN s.stocks > 0 THEN 1 ELSE 0 END) AS "Over Stock",
    SUM(CASE WHEN s.stocks = 0 THEN 1 ELSE 0 END) AS "Under Stock"
    FROM
    stocks s
GROUP BY
    s.product_type
ORDER BY
    product_type;

# --------------------------------------------- END -------------------------------------------------------- #
 
 
 
 
 



WITH MTD As (
SELECT  Month(s.date) AS Month,
SUM(p.sales_amount) AS Sales
FROM
 sales AS s
 JOIN 
 point_of_sale AS p
 ON
 s.Order_Number = p.Order_Number 
 GROUP BY Month
 )
SELECT
Month,
Sales,
SUM(Sales)
OVER (ORDER BY Month) AS MTD 
FROM MTD;
