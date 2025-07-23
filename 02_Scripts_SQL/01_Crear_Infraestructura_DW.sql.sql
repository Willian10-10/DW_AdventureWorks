--------------------------------------------------------------------------------
-- SCRIPT 01: CREAR INFRAESTRUCTURA DEL DATA WAREHOUSE
-- Propósito: Prepara el entorno físico para el DW.
--------------------------------------------------------------------------------

-- PASO 1: CONECTAR A MASTER Y ELIMINAR BD ANTERIOR
--------------------------------------------------------------------------------
USE master;
GO

IF DB_ID('DW_AdventureWorks') IS NOT NULL
BEGIN
    ALTER DATABASE DW_AdventureWorks SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DW_AdventureWorks;
    PRINT 'Base de datos DW_AdventureWorks anterior eliminada.';
END
GO

--------------------------------------------------------------------------------
-- PASO 2: CREAR BASE DE DATOS Y FILEGROUPS
-- Separa físicamente los datos de dimensiones, hechos y el log.
--------------------------------------------------------------------------------
CREATE DATABASE DW_AdventureWorks
ON PRIMARY 
( 
    NAME = N'DW_AdventureWorks_mdf', 
    FILENAME = N'C:\DW_DATA\MDF\DW_AdventureWorks.mdf'
),
FILEGROUP FG_DIMENSIONS
( 
    NAME = N'DW_AdventureWorks_dims_ndf', 
    FILENAME = N'C:\DW_DATA\DIMENSIONS\DW_AdventureWorks_dims.ndf'
),
FILEGROUP FG_FACTS
( 
    NAME = N'DW_AdventureWorks_facts_ndf', 
    FILENAME = N'C:\DW_DATA\FACTS\DW_AdventureWorks_facts.ndf'
)
LOG ON 
( 
    NAME = N'DW_AdventureWorks_log', 
    FILENAME = N'C:\DW_DATA\LDF\DW_AdventureWorks.log'
);
GO

PRINT 'Base de datos DW_AdventureWorks y filegroups creados.';
GO

--------------------------------------------------------------------------------
-- PASO 3: CONFIGURAR MODO DE RECUPERACIÓN A SIMPLE
-- Optimiza el rendimiento durante las cargas masivas de datos (ETL).
--------------------------------------------------------------------------------
ALTER DATABASE DW_AdventureWorks SET RECOVERY SIMPLE;
GO

--------------------------------------------------------------------------------
-- PASO 4: CREAR ESQUEMA DE PARTICIONAMIENTO POR FECHA
-- Divide la tabla de hechos en trozos más pequeños (por año) para acelerar consultas.
--------------------------------------------------------------------------------
USE DW_AdventureWorks;
GO

-- Define los límites de las particiones (inicio de cada año)
CREATE PARTITION FUNCTION PF_VentasPorFecha (INT)
AS RANGE RIGHT FOR VALUES (20120101, 20130101, 20140101);
GO

-- Asigna las particiones creadas al filegroup de los hechos (FG_FACTS)
CREATE PARTITION SCHEME PS_VentasPorFecha
AS PARTITION PF_VentasPorFecha
ALL TO (FG_FACTS);
GO

PRINT 'Esquema de particionamiento creado.';
GO

PRINT '--- SCRIPT 01 FINALIZADO ---';
GO