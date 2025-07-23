--------------------------------------------------------------------------------
-- SCRIPT 03: CARGAR DATOS EN EL DW (VERSIÓN 4 - DEFINITIVA)
-- Propósito: Carga los datos con la lógica final que se ajusta a la nueva
--            llave primaria de la tabla de hechos.
--------------------------------------------------------------------------------
USE DW_AdventureWorks;
GO

-- PASO 0: LIMPIEZA DE TABLAS
PRINT 'Vaciando tablas para la carga...';
TRUNCATE TABLE dbo.FactInternetSales;
TRUNCATE TABLE dbo.DimCliente;
TRUNCATE TABLE dbo.DimProducto;
TRUNCATE TABLE dbo.DimTerritorio;
TRUNCATE TABLE dbo.DimTiempo;
GO

-- PASO 1: CARGAR DimCliente
PRINT 'Cargando DimCliente...';
INSERT INTO dbo.DimCliente (CustomerID_Original, FullName, EmailAddress)
SELECT DISTINCT c.CustomerID, ISNULL(p.FirstName, '') + ' ' + ISNULL(p.LastName, ''), ea.EmailAddress
FROM AdventureWorks2019.Sales.Customer AS c
INNER JOIN AdventureWorks2019.Person.Person AS p ON c.PersonID = p.BusinessEntityID
INNER JOIN AdventureWorks2019.Person.EmailAddress AS ea ON p.BusinessEntityID = ea.BusinessEntityID;
GO

-- PASO 2: CARGAR DimProducto
PRINT 'Cargando DimProducto...';
INSERT INTO dbo.DimProducto (ProductID_Original, ProductName, SubcategoryName, CategoryName, StandardCost, Color)
SELECT p.ProductID, p.Name, s.Name, c.Name, p.StandardCost, p.Color
FROM AdventureWorks2019.Production.Product AS p
LEFT JOIN AdventureWorks2019.Production.ProductSubcategory AS s ON p.ProductSubcategoryID = s.ProductSubcategoryID
LEFT JOIN AdventureWorks2019.Production.ProductCategory AS c ON s.ProductCategoryID = c.ProductCategoryID;
GO

-- PASO 3: CARGAR DimTerritorio
PRINT 'Cargando DimTerritorio...';
INSERT INTO dbo.DimTerritorio (TerritoryName, CountryRegionCode, [Group])
SELECT Name, CountryRegionCode, [Group]
FROM AdventureWorks2019.Sales.SalesTerritory;
GO

-- PASO 4: CARGAR DimTiempo
PRINT 'Cargando DimTiempo...';
DECLARE @FechaInicio DATE = (SELECT MIN(OrderDate) FROM AdventureWorks2019.Sales.SalesOrderHeader);
DECLARE @FechaFin DATE = (SELECT MAX(OrderDate) FROM AdventureWorks2019.Sales.SalesOrderHeader);
WITH Fechas AS (SELECT @FechaInicio AS Fecha UNION ALL SELECT DATEADD(day, 1, Fecha) FROM Fechas WHERE Fecha < @FechaFin)
INSERT INTO dbo.DimTiempo (DateKey, FullDate, Year, Quarter, Month, MonthName)
SELECT CONVERT(INT, CONVERT(VARCHAR(8), Fecha, 112)), Fecha, YEAR(Fecha), DATEPART(quarter, Fecha), MONTH(Fecha), FORMAT(Fecha, 'MMMM', 'es-ES')
FROM Fechas OPTION (MAXRECURSION 0);
GO

-- PASO 5: CARGAR FactInternetSales (CON LA LÓGICA FINAL)
PRINT 'Cargando FactInternetSales...';
INSERT INTO dbo.FactInternetSales (
    CustomerKey, ProductKey, DateKey, SalesTerritoryKey,
    SalesOrderID_Original, SalesOrderDetailID_Original, -- Columnas nuevas
    MontoDeVenta, CantidadVendida, CostoTotal
)
SELECT
    dc.CustomerKey,
    dp.ProductKey,
    dt.DateKey,
    ISNULL(dtr.SalesTerritoryKey, -1),
    soh.SalesOrderID,       -- Se inserta el ID de la orden
    sod.SalesOrderDetailID, -- Se inserta el ID del detalle
    sod.LineTotal,
    sod.OrderQty,
    p.StandardCost * sod.OrderQty
FROM 
    AdventureWorks2019.Sales.SalesOrderHeader AS soh
INNER JOIN 
    AdventureWorks2019.Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN
    AdventureWorks2019.Production.Product AS p ON sod.ProductID = p.ProductID
INNER JOIN
    dbo.DimCliente AS dc ON soh.CustomerID = dc.CustomerID_Original
INNER JOIN
    dbo.DimProducto AS dp ON sod.ProductID = dp.ProductID_Original
INNER JOIN
    dbo.DimTiempo AS dt ON CONVERT(DATE, soh.OrderDate) = dt.FullDate
LEFT JOIN 
    AdventureWorks2019.Sales.SalesTerritory AS st ON soh.TerritoryID = st.TerritoryID
LEFT JOIN
    dbo.DimTerritorio AS dtr ON st.Name = dtr.TerritoryName COLLATE DATABASE_DEFAULT;
GO

PRINT '--- SCRIPT 03 FINALIZADO ---';
GO