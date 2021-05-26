-- make a new database
CREATE DATABASE TemporalTables;
GO
USE TemporalTables;
GO


--Conditions 
--1. Primary Key
--2. datetime column with - " GENERATED ALWAYS AS ROW START / END"
--3. PERIOD FOR SYSTEM_TIME (column name )
--4. WITH (SYSTEM_VERSIONING = ON);

-- create temporal table to store products

ALTER TABLE dbo.Products SET (SYSTEM_VERSIONING = OFF)
drop table   dbo.Products;

CREATE TABLE dbo.Products (
    ProductID int IDENTITY(1,1) PRIMARY KEY,
    ProductName nvarchar(50) NOT NULL,
    ProductPrice smallmoney NOT NULL,
    ValidFrom datetime2 (2) GENERATED ALWAYS AS ROW START  HIDDEN,
    ValidTo datetime2 (2) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON);
GO

-- insert values into the products table
INSERT dbo.Products (ProductName, ProductPrice)
    VALUES  ('Mixed Nuts',3.99),
            ('Shelled Peanuts',5.49),
            ('Roasted Almonds',7.29);
GO

-- see the current state of the data
SELECT * FROM dbo.Products1;
GO

-- get the current UTC date and time
SELECT GETUTCDATE();
GO

-- update a price in the products table
UPDATE dbo.Products
    Set ProductPrice = '6.99'
    WHERE ProductName = 'Roasted Almonds';
GO

-- see the current state of the data
SELECT * FROM dbo.Products;
GO

-- see the historic pricing as of a few moments ago
SELECT * FROM dbo.Products
    FOR SYSTEM_TIME
        AS OF '<insert date and time here>';
GO

-- see the full pricing history of the Roasted Almonds product
SELECT * FROM dbo.Products
    FOR SYSTEM_TIME
        BETWEEN '2000-01-01' AND '9999-12-31'
            WHERE ProductName = 'Roasted Almonds'
            ORDER BY ValidFrom;
GO

-- delete database
USE tempdb;
GO
DROP DATABASE TemporalTables;
GO

--ALTER

CREATE SCHEMA History;
GO

ALTER TABLE InsurancePolicy
    ADD
        SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN
            CONSTRAINT DF_SysStart DEFAULT SYSUTCDATETIME()
      , SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN
            CONSTRAINT DF_SysEnd DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
        PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime);
GO

ALTER TABLE InsurancePolicy
    SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = History.InsurancePolicy));