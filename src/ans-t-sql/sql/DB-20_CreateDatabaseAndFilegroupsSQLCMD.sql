/******************************************************************************************
------------------------------------------------------------------
CREATE DATABASE DataCloud2
NOTE! THIS VERSION ONLY WORKS WITH SQLCMD ON LINUX MACHINES
------------------------------------------------------------------
Create Date:        2021-09-04
Author:             Henryk Telega
Description:        This script creates database DataCloud2. 
                    and creates filegroups for tables.
NOTE:               DO NOT RUN THIS SCRIPT IN SSMS. 
                    RUN create_database.sh script instead!!!
USAGE:
					1. check paths in file create database.sh, edit variables (paths) if needed
					2. run script create_database.sh
******************************************************************************************/
:ON ERROR EXIT

USE master;
GO

IF NOT EXISTS (SELECT name FROM master.sys.databases 
	WHERE name = 'DataCloud') 
	CREATE DATABASE DataCloud;
ELSE
	RAISERROR('Stopping execution because DataCloud database already exists. Drop it first. You can run drop_database.sh script on a Linux machine or run DB-10_DropDatabase.sql (this works on Linux and Windows).',16,0);
GO

IF EXISTS (SELECT name FROM master.sys.databases 
	WHERE name = 'DataCloud') 
BEGIN
	ALTER DATABASE DataCloud ADD FILEGROUP OriginalTemperaturesFG;
	ALTER DATABASE DataCloud ADD FILEGROUP ANSTemperaturesFG;
	ALTER DATABASE DataCloud ADD FILEGROUP CompressTemperaturesFG;
	ALTER DATABASE DataCloud 
	ADD FILE (NAME = 'OriginalTemp', 
			  FILENAME = N'$(varOriginalFileName)'
			  )
	TO FILEGROUP OriginalTemperaturesFG;
	ALTER DATABASE DataCloud 
	ADD FILE (NAME = 'ANSTemp', 
			  FILENAME = N'$(varANSFileName)'
			  )
	TO FILEGROUP ANSTemperaturesFG;
	ALTER DATABASE DataCloud 
	ADD FILE (NAME = 'CompressTemp', 
			  FILENAME = N'$(varCompressFileName)'
			  )
	TO FILEGROUP CompressTemperaturesFG;
END
GO

