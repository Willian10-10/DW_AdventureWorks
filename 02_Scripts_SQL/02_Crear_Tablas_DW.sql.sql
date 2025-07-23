--------------------------------------------------------------------------------
-- SCRIPT 02: CREAR TABLAS DEL DATA WAREHOUSE (VERSIÓN 3 - DEFINITIVA)
-- Propósito: Crea el esquema estrella con la estructura final y correcta
--            para la tabla de hechos, evitando claves duplicadas.
--------------------------------------------------------------------------------
USE DW_AdventureWorks;
GO

--------------------------------------------------------------------------------
-- PASO 1: CREAR TABLAS DE DIMENSIÓN
--------------------------------------------------------------------------------
PRINT 'Creando Tablas de Dimensión...';

CREATE TABLE dbo.DimCliente (
    CustomerKey         INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID_Original INT,
    FullName            NVARCHAR(150) NOT NULL,
    EmailAddress        NVARCHAR(50) NULL
) ON FG_DIMENSIONS;

CREATE TABLE dbo.DimProducto (
    ProductKey          INT IDENTITY(1,1) PRIMARY KEY,
    ProductID_Original  INT,
    ProductName         NVARCHAR(50) NOT NULL,
    SubcategoryName     NVARCHAR(50) NULL,
    CategoryName        NVARCHAR(50) NULL,
    StandardCost        MONEY NULL,
    Color               NVARCHAR(15) NULL
) ON FG_DIMENSIONS;

CREATE TABLE dbo.DimTiempo (
    DateKey             INT PRIMARY KEY,
    FullDate            DATE NOT NULL,
    Year                INT NOT NULL,
    Quarter             TINYINT NOT NULL,
    Month               TINYINT NOT NULL,
    MonthName           NVARCHAR(20) NOT NULL
) ON FG_DIMENSIONS;

CREATE TABLE dbo.DimTerritorio (
    SalesTerritoryKey   INT IDENTITY(1,1) PRIMARY KEY,
    TerritoryName       NVARCHAR(50) NOT NULL,
    CountryRegionCode   NVARCHAR(3) NOT NULL,
    [Group]             NVARCHAR(50) NOT NULL
) ON FG_DIMENSIONS;
GO

--------------------------------------------------------------------------------
-- PASO 2: CREAR TABLA DE HECHOS (CON ESTRUCTURA CORREGIDA)
--------------------------------------------------------------------------------
PRINT 'Creando Tabla de Hechos con llave primaria corregida...';

CREATE TABLE dbo.FactInternetSales (
    -- Llaves de Dimensión
    CustomerKey         INT NOT NULL,
    ProductKey          INT NOT NULL,
    DateKey             INT NOT NULL, 
    SalesTerritoryKey   INT NOT NULL,
    
    -- Llaves de Negocio para garantizar unicidad
    SalesOrderID_Original       INT NOT NULL,
    SalesOrderDetailID_Original INT NOT NULL,

    -- Medidas
    MontoDeVenta        MONEY NOT NULL,
    CantidadVendida     INT NOT NULL,
    CostoTotal          MONEY NOT NULL,

    -- Llave primaria robusta que incluye el identificador único de la transacción
    CONSTRAINT PK_FactInternetSales PRIMARY KEY CLUSTERED 
    (
        DateKey, -- Mantenemos DateKey primero por el particionamiento
        SalesOrderID_Original,
        SalesOrderDetailID_Original
    )
) ON PS_VentasPorFecha(DateKey);
GO

PRINT '--- SCRIPT 02 FINALIZADO ---';
GO

