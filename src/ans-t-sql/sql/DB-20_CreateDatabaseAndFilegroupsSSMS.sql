/******************************************************************************************
------------------------------------------------------------------
CREATE DATABASE DataCloud
THIS VERSION WORKS ON Windows AND Linux machines.
NOTE! 
------------------------------------------------------------------
Create Date:        2021-09-06
Author:             Henryk Telega
Description:        This script creates database DataCloud. 
                    and creates filegroups for tables.
NOTES:              YOU CAN RUN THIS SCRIPT IN SSMS. 
                    CHECK PATHS FOR ALL FILES AND EDIT THEM IF NEEDED!
******************************************************************************************/

USE master;
GO

IF NOT EXISTS (SELECT name FROM master.sys.databases 
	WHERE name = 'DataCloud') 
	CREATE DATABASE DataCloud;
ELSE
	THROW 51000, 'Stopping execution because DataCloud database already exists. Drop it first. You can DB-10_DropDatabase.sql.',0;
GO

IF EXISTS (SELECT name FROM master.sys.databases 
	WHERE name = 'DataCloud') 
BEGIN
	ALTER DATABASE DataCloud ADD FILEGROUP OriginalTemperaturesFG;
	ALTER DATABASE DataCloud ADD FILEGROUP ANSTemperaturesFG;
	ALTER DATABASE DataCloud ADD FILEGROUP CompressTemperaturesFG;
	ALTER DATABASE DataCloud 
	ADD FILE (NAME = 'OriginalTemp', 
			  FILENAME = N'C:\ANSDatabase\datacloud_oryginaltemp.ndf' -- CHANGE THE PATH IF NEEDED!!!
			  )
	TO FILEGROUP OriginalTemperaturesFG;
	ALTER DATABASE DataCloud 
	ADD FILE (NAME = 'ANSTemp', 
			  FILENAME = N'C:\ANSDatabase\datacloud_anstemp.ndf'
			  )
	TO FILEGROUP ANSTemperaturesFG;
	ALTER DATABASE DataCloud 
	ADD FILE (NAME = 'CompressTemp', 
			  FILENAME = N'C:\ANSDatabase\datacloud_compresstemp.ndf'
			  )
	TO FILEGROUP CompressTemperaturesFG;
END
GO

