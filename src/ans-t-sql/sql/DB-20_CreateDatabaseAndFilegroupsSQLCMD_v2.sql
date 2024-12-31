/******************************************************************************************
------------------------------------------------------------------
CREATE DATABASE DataCloud2
NOTE! THIS VERSION ONLY WORKS WITH SQLCMD ON LINUX MACHINES
------------------------------------------------------------------
Create Date:        2021-09-24
Author:             Henryk Telega
Description:        This script creates database DataCloud2. 
                    and creates filegroups for tables.
NOTE:               DO NOT RUN THIS SCRIPT IN SSMS. 
                    RUN create_database_v2.sh script instead!!!
USAGE:
					1. check paths in file create database_v2.sh, edit variables (paths) if needed
					2. run script create_database_v2.sh
******************************************************************************************/
:ON ERROR EXIT

USE master;
GO

IF NOT EXISTS (SELECT name FROM master.sys.databases 
	WHERE name = 'DataCloud2') 
	CREATE DATABASE DataCloud2;
ELSE
	RAISERROR('Stopping execution because DataCloud2 database already exists. Drop it first. You can run drop_database.sh script on a Linux machine or run DB-10_DropDatabase.sql (this works on Linux and Windows).',16,0);
GO

IF EXISTS (SELECT name FROM master.sys.databases 
	WHERE name = 'DataCloud2') 
BEGIN
	ALTER DATABASE DataCloud2 ADD FILEGROUP OriginalTemperaturesFG;
	ALTER DATABASE DataCloud2 ADD FILEGROUP ANSTemperaturesFG;
	ALTER DATABASE DataCloud2 ADD FILEGROUP CompressTemperaturesFG;
	ALTER DATABASE DataCloud2 
	ADD FILE (NAME = 'OriginalTemp', 
			  FILENAME = N'$(varOriginalFileName)'
			  )
	TO FILEGROUP OriginalTemperaturesFG;
	ALTER DATABASE DataCloud2 
	ADD FILE (NAME = 'ANSTemp', 
			  FILENAME = N'$(varANSFileName)'
			  )
	TO FILEGROUP ANSTemperaturesFG;
	ALTER DATABASE DataCloud2 
	ADD FILE (NAME = 'CompressTemp', 
			  FILENAME = N'$(varCompressFileName)'
			  )
	TO FILEGROUP CompressTemperaturesFG;
END
GO

