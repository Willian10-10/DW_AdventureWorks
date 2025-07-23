--------------------------------------------------------------------------------
-- SCRIPT 04: CREAR RESTRICCIONES E �NDICES
-- Prop�sito: Finaliza la construcci�n del DW estableciendo la integridad
--            referencial (Foreign Keys) y optimizando el rendimiento
--            de las consultas a trav�s de �ndices.
--------------------------------------------------------------------------------
USE DW_AdventureWorks;
GO

--------------------------------------------------------------------------------
-- PASO 1: CREAR RESTRICCIONES DE LLAVE FOR�NEA (FOREIGN KEYS)
-- Conectan la tabla de hechos a cada una de sus dimensiones.
--------------------------------------------------------------------------------
PRINT 'Creando Restricciones de Llave For�nea...';

ALTER TABLE dbo.FactInternetSales ADD CONSTRAINT FK_FactInternetSales_DimCliente
FOREIGN KEY (CustomerKey) REFERENCES dbo.DimCliente(CustomerKey);

ALTER TABLE dbo.FactInternetSales ADD CONSTRAINT FK_FactInternetSales_DimProducto
FOREIGN KEY (ProductKey) REFERENCES dbo.DimProducto(ProductKey);

ALTER TABLE dbo.FactInternetSales ADD CONSTRAINT FK_FactInternetSales_DimTiempo
FOREIGN KEY (DateKey) REFERENCES dbo.DimTiempo(DateKey);

ALTER TABLE dbo.FactInternetSales ADD CONSTRAINT FK_FactInternetSales_DimTerritorio
FOREIGN KEY (SalesTerritoryKey) REFERENCES dbo.DimTerritorio(SalesTerritoryKey);
GO

PRINT '--> Restricciones creadas exitosamente.';
GO

--------------------------------------------------------------------------------
-- PASO 2: CREAR �NDICES NO AGRUPADOS (NONCLUSTERED INDEXES)
-- Mejoran la velocidad de las b�squedas y los JOINs.
--------------------------------------------------------------------------------
PRINT 'Creando �ndices para optimizaci�n...';

-- 1. �ndices en las llaves de negocio de las dimensiones.
--    Esto acelera la b�squeda de llaves surrogate durante el proceso ETL.
--------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_DimCliente_CustomerID_Original ON dbo.DimCliente(CustomerID_Original);
CREATE NONCLUSTERED INDEX IX_DimProducto_ProductID_Original ON dbo.DimProducto(ProductID_Original);
GO

-- 2. �ndices en cada llave for�nea de la tabla de hechos.
--    Esto acelera dr�sticamente los JOINs entre la tabla de hechos y las
--    dimensiones cuando se realizan consultas anal�ticas.
--------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_FactInternetSales_CustomerKey ON dbo.FactInternetSales(CustomerKey);
CREATE NONCLUSTERED INDEX IX_FactInternetSales_ProductKey ON dbo.FactInternetSales(ProductKey);
CREATE NONCLUSTERED INDEX IX_FactInternetSales_SalesTerritoryKey ON dbo.FactInternetSales(SalesTerritoryKey);
-- No creamos uno en DateKey porque ya es la primera columna del �ndice clustered (la PK).
GO

PRINT '--> �ndices creados exitosamente.';
GO

PRINT '--- SCRIPT 04 FINALIZADO ---';
GO