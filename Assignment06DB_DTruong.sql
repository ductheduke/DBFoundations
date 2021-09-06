--*************************************************************************--
-- Title: Assignment06
-- Author: DTruong
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-09-05,DTruong,Created File
-- 2021-09-06,DTruong,Completed File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_DTruong')
	 Begin 
	  Alter Database [Assignment06DB_DTruong] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_DTruong;
	 End
	Create Database Assignment06DB_DTruong;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_DTruong;
go

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
--NOTES------------------------------------------------------------------------------------ 
--1) You can use any name you like for you views, but be descriptive and consistent
--2) You can use your working code from assignment 5 for much of this assignment
--3) You must use the BASIC views for each table after they are created in Question 1
-------------------------------------------------------------------------------------------

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

-- Create View for Categories table
CREATE VIEW vCategories
WITH SCHEMABINDING
AS
 Select CategoryID, CategoryName From dbo.Categories;
GO
-- Create View for Products table
CREATE VIEW vProducts
WITH SCHEMABINDING
AS
 Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
GO
-- Create View for Employees table
CREATE VIEW vEmployees
WITH SCHEMABINDING
AS
 Select EmployeeID, EmployeeName = EmployeeFirstName + ' ' + EmployeeLastName, ManagerID From dbo.Employees;
GO
-- Create View for Inventories table
CREATE VIEW vInventories
WITH SCHEMABINDING
AS
 Select InventoryID, InventoryDate, EmployeeID, ProductID, Count From dbo.Inventories;
GO
-- Test these Views
Select * From dbo.vCategories
Select * From dbo.vProducts
Select * From dbo.vInventories
Select * From dbo.vEmployees
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- Set permissions for vCategories view
Deny Select On Categories to Public;
Grant Select On vCategories to Public;
GO
-- Set permissions for vProducts view
Deny Select On Products to Public;
Grant Select On vProducts to Public;
GO
-- Set permissions for vEmployees view
Deny Select On Employees to Public;
Grant Select On vEmployees to Public;
GO
-- Set permissions for vInventories view
Deny Select On Inventories to Public;
Grant Select On vInventories to Public;
GO


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

CREATE VIEW vProductsByCategories
AS
	SELECT TOP 1000000 C.CategoryName, P.ProductName, P.UnitPrice
	FROM vCategories as C
	INNER JOIN vProducts as P
	ON C.CategoryID = P.CategoryID
	ORDER BY 1,2;
GO
-- Test this View
Select * From [dbo].[vProductsByCategories]
GO


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

CREATE VIEW vInventoriesByProductsByDates
AS
	SELECT TOP 1000000 P.ProductName, I.InventoryDate, I.Count
	FROM vProducts as P
	INNER JOIN vInventories as I
	ON P.ProductID = I.ProductID
	ORDER BY 2,1,3;
GO
-- Test this View
Select * From [dbo].[vInventoriesByProductsByDates]
GO


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

CREATE VIEW vInventoriesByEmployeesByDates
AS
	SELECT DISTINCT TOP 1000000 I.InventoryDate, E.EmployeeName
	FROM vInventories as I
	INNER JOIN vEmployees as E
	ON I.EmployeeID = E.EmployeeID
	ORDER BY 1;
GO
-- Test this View
Select * From [dbo].[vInventoriesByEmployeesByDates]
GO


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

CREATE VIEW vInventoriesByProductsByCategories
AS
	SELECT TOP 1000000 
		C.CategoryName
		,P.ProductName
		,I.InventoryDate
		,I.Count
	FROM vCategories as C
	INNER JOIN vProducts as P
	ON C.CategoryID = P.CategoryID
	INNER JOIN vInventories as I
	ON P.ProductID = I.ProductID
	ORDER BY 1,2,3,4;
go
-- Test this View
Select * From [dbo].[vInventoriesByProductsByCategories]
GO


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

CREATE VIEW vInventoriesByProductsByEmployees
AS
	SELECT TOP 1000000 
		C.CategoryName
		,P.ProductName
		,I.InventoryDate
		,I.Count
		,E.EmployeeName
	FROM vCategories as C
	INNER JOIN vProducts as P
	ON C.CategoryID = P.CategoryID
	INNER JOIN vInventories as I
	ON P.ProductID = I.ProductID
	INNER JOIN vEmployees as E
	ON I.EmployeeID = E.EmployeeID
	ORDER BY 1,2,3,5;
GO
-- Test this View
Select * From [dbo].[vInventoriesByProductsByEmployees]
GO


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

CREATE VIEW vInventoriesForChaiAndChangByEmployees
AS
	SELECT TOP 1000000 
		C.CategoryName
		,P.ProductName
		,I.InventoryDate
		,I.Count
		,E.EmployeeName
	FROM vCategories as C
	INNER JOIN vProducts as P
	ON C.CategoryID = P.CategoryID
	INNER JOIN vInventories as I
	ON P.ProductID = I.ProductID
	INNER JOIN vEmployees as E
	ON I.EmployeeID = E.EmployeeID
	WHERE P.ProductID IN
	(SELECT ProductID FROM vProducts WHERE ProductName IN ('Chai', 'Chang'))
	ORDER BY 3,1,2;
GO
-- Test this View
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
GO


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

CREATE VIEW vEmployeesByManager
AS
	SELECT TOP 1000000 
		M.EmployeeName as Manager
		,E.EmployeeName as Employee 
	FROM vEmployees as E 
	INNER JOIN vEmployees as M
	ON E.ManagerID = M.EmployeeID
	ORDER BY 1,2;   
GO
-- Test this View
Select * From [dbo].[vEmployeesByManager]
GO


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
--1	Beverages	1	Chai	18.00	1	2017-01-01	19	5	Steven Buchanan	Andrew Fuller
--1	Beverages	1	Chai	18.00	78	2017-02-01	1	7	Robert King	Steven Buchanan
--1	Beverages	1	Chai	18.00	155	2017-03-01	94	9	Anne Dodsworth	Steven Buchanan
--1	Beverages	2	Chang	19.00	2	2017-01-01	17	5	Steven Buchanan	Andrew Fuller
--1	Beverages	2	Chang	19.00	79	2017-02-01	79	7	Robert King	Steven Buchanan
--1	Beverages	2	Chang	19.00	156	2017-03-01	37	9	Anne Dodsworth	Steven Buchanan
--1	Beverages	24	Guaran� Fant�stica	4.50	24	2017-01-01	0	5	Steven Buchanan	Andrew Fuller
--1	Beverages	24	Guaran� Fant�stica	4.50	101	2017-02-01	79	7	Robert King	Steven Buchanan
--1	Beverages	24	Guaran� Fant�stica	4.50	178	2017-03-01	28	9	Anne Dodsworth	Steven Buchanan
--1	Beverages	34	Sasquatch Ale	14.00	34	2017-01-01	5	5	Steven Buchanan	Andrew Fuller
--1	Beverages	34	Sasquatch Ale	14.00	111	2017-02-01	64	7	Robert King	Steven Buchanan
--1	Beverages	34	Sasquatch Ale	14.00	188	2017-03-01	86	9	Anne Dodsworth	Steven Buchanan
--1	Beverages	35	Steeleye Stout	18.00	35	2017-01-01	81	5	Steven Buchanan	Andrew Fuller
--1	Beverages	35	Steeleye Stout	18.00	112	2017-02-01	41	7	Robert King	Steven Buchanan
--1	Beverages	35	Steeleye Stout	18.00	189	2017-03-01	3	9	Anne Dodsworth	Steven Buchanan
--1	Beverages	38	C�te de Blaye	263.50	38	2017-01-01	49	5	Steven Buchanan	Andrew Fuller
--1	Beverages	38	C�te de Blaye	263.50	115	2017-02-01	62	7	Robert King	Steven Buchanan
--1	Beverages	38	C�te de Blaye	263.50	192	2017-03-01	92	9	Anne Dodsworth	Steven Buchanan
--1	Beverages	39	Chartreuse verte	18.00	39	2017-01-01	11	5	Steven Buchanan	Andrew Fuller



CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
AS
	SELECT TOP 1000000 
		C.CategoryID
		,C.CategoryName
		,P.ProductID
		,P.ProductName
		,P.UnitPrice
		,I.InventoryID
		,I.InventoryDate
		,I.Count
		,E.EmployeeName as Employee
		,M.EmployeeName as Manager
	FROM vCategories as C
	INNER JOIN vProducts as P
	ON C.CategoryID = P.CategoryID
	INNER JOIN vInventories as I
	ON P.ProductID = I.ProductID
	INNER JOIN vEmployees as E
	ON I.EmployeeID = E.EmployeeID
	INNER JOIN vEmployees as M
	ON E.ManagerID = M.EmployeeID
	ORDER BY 1,3,6,9;
GO
-- Test this View
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
GO

/***************************************************************************************/