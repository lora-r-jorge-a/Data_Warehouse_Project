/*
=============================================
Script to create Database and Schemas
=============================================

Description:
	The following script checks if there is a database with the next name: Data_Warehouse_JL.
	If exists, the database will be dropped and created from scratch. Otherwise,
	the database will be created without dropping any database or object. Also,
	three schemas will be created: Bronze, Silver and Gold.

Warning:
	Any active transaction on Data_Warehouse_JL database will be rolled back and 
	Data_Warehouse_JL will be dropped including all data in it. Consider creating a 
	backup if you do not wish to be deleted before running this script.
*/

USE master;
GO
--Creating Database

--Check for existing database with the same name, if exits, is dropped and created
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Data_Warehouse_JL' )
BEGIN
	ALTER DATABASE Data_Warehouse_JL SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Data_Warehouse_JL;
END;
GO

CREATE DATABASE Data_Warehouse_JL;
GO

USE Data_Warehouse_JL;
GO

--Creating Schemas
CREATE SCHEMA Bronze;
GO
CREATE SCHEMA Silver;
GO
CREATE SCHEMA Gold;
GO
