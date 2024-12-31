/******************************************************************************************
------------------------------------------------------------------
CREATE DATABASE DataCloud
THIS VERSION WORKS ON Windows AND Linux machines.
NOTE! 
------------------------------------------------------------------
Create Date:        2021-09-24
Author:             Henryk Telega
Description:        This script creates database DataCloud2. 
                    and creates filegroups for tables.
NOTES:              YOU CAN RUN THIS SCRIPT IN SSMS. 
                    CHECK PATHS FOR ALL FILES AND EDIT THEM IF NEEDED!
******************************************************************************************/

USE master;
GO

IF NOT EXISTS (SELECT name FROM master.sys.databases 
	WHERE name = 'DataCloud2') 
	CREATE DATABASE DataCloud2;
ELSE
	THROW 51000, 'Stopping execution because DataCloud2 database already exists. Drop it first. You can DB-10_DropDatabase.sql.',0;
GO

IF EXISTS (SELECT name FROM master.sys.databases 
	WHERE name = 'DataCloud2') 
BEGIN
	ALTER DATABASE DataCloud2 ADD FILEGROUP OriginalTemperaturesFG;
	ALTER DATABASE DataCloud2 ADD FILEGROUP ANSTemperaturesFG;
	ALTER DATABASE DataCloud2 ADD FILEGROUP CompressTemperaturesFG;
	ALTER DATABASE DataCloud2 
	ADD FILE (NAME = 'OriginalTemp', 
			  FILENAME = N'C:\ANSDatabase2\datacloud_oryginaltemp.ndf' -- CHANGE THE PATH IF NEEDED!!!
			  )
	TO FILEGROUP OriginalTemperaturesFG;
	ALTER DATABASE DataCloud2 
	ADD FILE (NAME = 'ANSTemp', 
			  FILENAME = N'C:\ANSDatabase2\datacloud_anstemp.ndf'
			  )
	TO FILEGROUP ANSTemperaturesFG;
	ALTER DATABASE DataCloud2 
	ADD FILE (NAME = 'CompressTemp', 
			  FILENAME = N'C:\ANSDatabase2\datacloud_compresstemp.ndf'
			  )
	TO FILEGROUP CompressTemperaturesFG;
END
GO

